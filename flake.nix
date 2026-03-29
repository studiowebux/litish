{
  description = "Isolated development environment — all tools, caches, and configs stay on a dedicated encrypted volume";

  inputs = {
    nixpkgs.url        = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
  };

  outputs = { self, nixpkgs }:
  let
    system = "aarch64-darwin";

    pkgs = nixpkgs.legacyPackages.${system};

    devDir = "/Volumes/studiowebux/Development";

    deno = pkgs.callPackage ./pkgs/deno.nix {};
    helix = pkgs.callPackage ./pkgs/helix.nix {};
    gh = pkgs.callPackage ./pkgs/gh.nix {};
    gopls = pkgs.callPackage ./pkgs/gopls.nix {};
    go = pkgs.callPackage ./pkgs/go.nix {};
    cerveau = pkgs.callPackage ./pkgs/cerveau.nix {};
    claude = pkgs.callPackage ./pkgs/claude.nix {};
    kubectl = pkgs.callPackage ./pkgs/kubectl.nix {};
    flux = pkgs.callPackage ./pkgs/flux.nix {};
    helm = pkgs.callPackage ./pkgs/helm.nix {};
    terraform = pkgs.callPackage ./pkgs/terraform.nix {};

    # LSP servers
    lua-language-server = pkgs.callPackage ./pkgs/lua-language-server.nix {};
    terraform-ls = pkgs.callPackage ./pkgs/terraform-ls.nix {};
    helm-ls = pkgs.callPackage ./pkgs/helm-ls.nix {};
    ols = pkgs.callPackage ./pkgs/ols.nix {};
    omnisharp = pkgs.callPackage ./pkgs/omnisharp.nix {};
    sshtui = pkgs.callPackage ./pkgs/sshtui.nix {};
    minimaldoc = pkgs.callPackage ./pkgs/minimaldoc.nix {};
    restcli = pkgs.callPackage ./pkgs/restcli.nix {};
    proxytui = pkgs.callPackage ./pkgs/proxytui.nix {};
    timeago = pkgs.callPackage ./pkgs/timeago.nix {};
    lspmcp = pkgs.callPackage ./pkgs/lspmcp.nix {};
    bujotui     = pkgs.callPackage ./pkgs/bujotui.nix {};
    bujotui-mcp = pkgs.callPackage ./pkgs/bujotui-mcp.nix {};

    commonPackages = [
      helix
      gh
      pkgs.git
      pkgs.zsh
      pkgs.nil                        # nix lsp
      pkgs.yaml-language-server       # yaml lsp
      pkgs.nodePackages.bash-language-server # bash lsp
      pkgs.nodePackages.prettier      # formatter
      pkgs.vscode-langservers-extracted # json, html, css lsp
      pkgs.jq
      restcli
      timeago
      bujotui
      bujotui-mcp
      cerveau
      claude
      lspmcp
    ];

    # Specialized LSP groups
    lspTs = [ pkgs.nodePackages.typescript-language-server ];
    lspPython = [ pkgs.pyright pkgs.ruff ];
    lspOps = [ terraform-ls helm-ls pkgs.dockerfile-language-server ];
    lspOdin = [ ols ];
    lspCsharp = [ omnisharp ];
    lspLua = [ lua-language-server ];


    cerveauCompletion  = ''cerveau completion zsh > $COMP_DIR/_cerveau'';
    ghCompletion       = ''gh completion -s zsh > $COMP_DIR/_gh'';
    denoCompletion     = ''deno completions zsh > $COMP_DIR/_deno'';
    kubectlCompletion  = ''kubectl completion zsh > $COMP_DIR/_kubectl'';
    fluxCompletion     = ''flux completion zsh > $COMP_DIR/_flux'';
    helmCompletion     = ''helm completion zsh > $COMP_DIR/_helm'';
    terraformCompletion = ''printf '#compdef terraform\nautoload -U +X bashcompinit && bashcompinit\ncomplete -o nospace -C terraform terraform\n' > $COMP_DIR/_terraform'';

    denoCompletions = ''
      ${ghCompletion}
      ${denoCompletion}
      ${cerveauCompletion}
    '';

    goCompletions = ''
      ${ghCompletion}
      ${cerveauCompletion}
    '';

    hxCompletions = ''
      ${ghCompletion}
      ${cerveauCompletion}
    '';

    opsCompletions = ''
      ${ghCompletion}
      ${cerveauCompletion}
      ${kubectlCompletion}
      ${fluxCompletion}
      ${helmCompletion}
      ${terraformCompletion}
    '';

    commonVersions = ''
      echo "Helix:   $(hx --version)"
      echo "Git:     $(git --version)"
      echo "Cerveau: $(cerveau version)"
      echo "Claude:  $(claude --version)"
      echo "Lspmcp:  $(lspmcp -version)"
      echo "Bujotui:     $(bujotui version)"
      echo "Bujotui-mcp: $(bujotui-mcp version)"
      echo "Restcli:     $(restcli --version)"
    '';

    mkPrompt = name: completions: ''
      export SHELL=${pkgs.zsh}/bin/zsh
      export ZDOTDIR=$(mktemp -d)

      cat > $ZDOTDIR/.zshrc << 'EOF'
      # XDG — keep everything on the volume
      export CLAUDE_CONFIG_DIR=${devDir}/.claude
      export XDG_CONFIG_HOME=${devDir}/.config
      export XDG_CACHE_HOME=${devDir}/.cache
      export XDG_DATA_HOME=${devDir}/.data
      export XDG_STATE_HOME=${devDir}/.state

      # Shell history
      export HISTFILE="${devDir}/.zsh_history"
      export HISTSIZE=10000
      export SAVEHIST=10000
      setopt APPEND_HISTORY
      setopt SHARE_HISTORY

      # Tool-specific paths
      export DENO_DIR=${devDir}/.deno
      export GOMODCACHE=${devDir}/gomodcache
      export GOENV=${devDir}/.config/go/env
      export GIT_CONFIG_GLOBAL=${devDir}/.gitconfig
      export KUBECONFIG=${devDir}/.kube/config
      export KUBECACHEDIR=${devDir}/.kube/cache
      export CERVEAU_HOME=${devDir}/cerveau
      export BUJOTUI_CONFIG_DIR=${devDir}/.config/bujotui
      export BUJOTUI_DATA_DIR=${devDir}/.data/bujotui
      export ANSIBLE_HOME=${devDir}/.ansible
      export OMNISHARPHOME=${devDir}/.omnisharp

      # Node/npm — prevent ~/. pollution
      export NPM_CONFIG_CACHE=${devDir}/.cache/npm
      export NODE_REPL_HISTORY=${devDir}/.node_repl_history

      # Helm
      export HELM_CONFIG_HOME=${devDir}/.config/helm
      export HELM_CACHE_HOME=${devDir}/.cache/helm
      export HELM_DATA_HOME=${devDir}/.data/helm

      # Terraform
      export TF_DATA_DIR=${devDir}/.terraform
      export TF_PLUGIN_CACHE_DIR=${devDir}/.terraform/plugin-cache
      export TF_CLI_CONFIG_FILE=${devDir}/.terraform/terraformrc
      export TF_LOG_PATH=${devDir}/.terraform/terraform.log

      # Telemetry — kill it all
      export DO_NOT_TRACK=1
      export DISABLE_TELEMETRY=1
      export DISABLE_ERROR_REPORTING=1
      export DISABLE_FEEDBACK_COMMAND=1
      export DISABLE_INSTALLATION_CHECKS=1
      export DENO_NO_UPDATE_CHECK=1
      export GH_NO_UPDATE_NOTIFIER=1
      export GH_PROMPT_DISABLED=1
      export HOMEBREW_NO_ANALYTICS=1
      export NPM_CONFIG_UPDATE_NOTIFIER=false
      export ASTRO_TELEMETRY_DISABLED=1
      export NEXT_TELEMETRY_DISABLED=1
      export DOTNET_CLI_TELEMETRY_OPTOUT=1
      export DOTNET_NOLOGO=1
      export SAM_CLI_TELEMETRY=0
      export CHECKPOINT_DISABLE=1
      export ANSIBLE_NOCOWS=1
      export ANSIBLE_NO_LOG=0
      export FLUX_NO_TELEMETRY=1
      export HELM_NO_UPDATE_NOTIFIER=1
      export CERVEAU_SKIP_BINARY_UPDATE=1

      setopt INTERACTIVE_COMMENTS

      COMP_DIR=${devDir}/.cache/zsh-completions/${name}
      if [ ! -d "$COMP_DIR" ]; then
        mkdir -p "$COMP_DIR"
        ${completions}
      fi
      fpath=($COMP_DIR $fpath)
      autoload -Uz compinit && compinit -d ${devDir}/.cache/zsh-completions/${name}/.zcompdump

      autoload -Uz vcs_info
      precmd() { vcs_info }
      zstyle ':vcs_info:git:*' formats ' %F{yellow}(%b)%f'
      setopt PROMPT_SUBST
      PROMPT='%F{blue}[${name}]%f %F{blue}%~%f''${vcs_info_msg_0_} %F{%(?.green.red)}❯%f '
      EOF

      exec ${pkgs.zsh}/bin/zsh
    '';

    mkShell = name: packages: completions: extra:
      pkgs.mkShell {
        packages = commonPackages ++ packages;
        shellHook = ''
          ${extra}
        '' + mkPrompt name completions;
      };

  in {

    devShells.${system} = {
      default = mkShell "all" ([ deno go gopls kubectl flux helm terraform pkgs.ansible sshtui minimaldoc proxytui
        pkgs.nmap pkgs.mtr pkgs.socat pkgs.tcpdump pkgs.curl pkgs.wget pkgs.dig pkgs.whois pkgs.netcat-gnu pkgs.openssl pkgs.bandwhich pkgs.aria2
        pkgs.mongodb-tools
      ]
        ++ lspTs ++ lspPython ++ lspOps ++ lspOdin ++ lspCsharp ++ lspLua
      ) opsCompletions ''
          export GOROOT=${go}
          export GOPATH=${devDir}/go
          export GOCACHE=${devDir}/.cache/go-build
          export PATH=${go}/bin:$GOPATH/bin:$PATH
          mkdir -p ${devDir}/.kube
          mkdir -p ${devDir}/.terraform/plugin-cache
          echo "Deno:      $(deno --version | head -1)"
          echo "Go:        $(go version)"
          echo "Gopls:     $(gopls version)"
          echo "Terraform: $(terraform version | head -1)"
          echo "Kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
          echo "Flux: $(flux --version)"
          echo "Helm: $(helm version --short)"
          echo "Ansible:    $(ansible --version | head -1)"
          echo "Sshtui:     $(sshtui --version)"
          echo "Minimaldoc: $(minimaldoc --version)"
          echo "Proxytui:   $(proxytui -version)"
          echo "Mongodump:  $(mongodump --version 2>&1 | head -1)"
          ${commonVersions}
      '';

      hx = mkShell "hx" ([]
        ++ lspTs ++ lspPython ++ lspOps ++ lspOdin ++ lspCsharp ++ lspLua
      ) hxCompletions ''
          ${commonVersions}
      '';

      deno = mkShell "deno" [ deno ] denoCompletions ''
          echo "Deno: $(deno --version)"
          ${commonVersions}
      '';

      go = mkShell "go" [ go gopls ] goCompletions ''
          export GOROOT=${go}
          export GOPATH=${devDir}/go
          export GOCACHE=${devDir}/.cache/go-build
          export PATH=${go}/bin:$GOPATH/bin:$PATH
          go telemetry off

          # install go tools if not present
          if ! command -v staticcheck &> /dev/null; then
            echo "installing staticcheck..."
            go install honnef.co/go/tools/cmd/staticcheck@latest
          fi

          if ! command -v gosec &> /dev/null; then
            echo "installing gosec..."
            go install github.com/securego/gosec/v2/cmd/gosec@latest
          fi

          if ! command -v govulncheck &> /dev/null; then
            echo "installing govulncheck..."
            go install golang.org/x/vuln/cmd/govulncheck@latest
          fi

          echo "Staticcheck: $(staticcheck --version)"
          echo "Gosec:       $(gosec --version)"
          echo "Govulncheck: $(govulncheck --version)"

          echo "Go:    $(go version)"
          echo "Gopls: $(gopls version)"
          ${commonVersions}
        '';
      ops = mkShell "ops" ([ kubectl flux helm terraform pkgs.ansible sshtui pkgs.mongodb-tools ]
        ++ lspOps
      ) opsCompletions ''
          mkdir -p ${devDir}/.kube
          mkdir -p ${devDir}/.terraform/plugin-cache
          echo "Terraform: $(terraform version | head -1)"
          echo "Kubectl:   $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
          echo "Flux:      $(flux --version)"
          echo "Helm: $(helm version --short)"
          echo "Ansible: $(ansible --version | head -1)"
          echo "Sshtui:    $(sshtui --version)"
          echo "Mongodump: $(mongodump --version 2>&1 | head -1)"
          ${commonVersions}
      '';

      game = mkShell "game" ([]
        ++ lspCsharp ++ lspOdin ++ lspLua
      ) hxCompletions ''
          ${commonVersions}
      '';

      net = mkShell "net" [
        sshtui
        proxytui
        pkgs.nmap
        pkgs.mtr
        pkgs.socat
        pkgs.tcpdump
        pkgs.curl
        pkgs.wget
        pkgs.dig
        pkgs.whois
        pkgs.netcat-gnu
        pkgs.openssl
        pkgs.jq
        pkgs.bandwhich
        pkgs.aria2
      ] hxCompletions ''
          echo "Nmap:      $(nmap --version | head -1)"
          echo "Mtr:       $(mtr --version)"
          echo "Socat:     $(socat -V | head -2 | tail -1)"
          echo "Tcpdump:   $(tcpdump --version 2>&1 | head -1)"
          echo "Curl:      $(curl --version | head -1)"
          echo "Wget:      $(wget --version | head -1)"
          echo "Dig:       $(dig -v 2>&1 | head -1)"
          echo "Whois:     $(whois --version 2>&1 | head -1 || echo "installed")"
          echo "Netcat:    $(nc --version 2>&1 | head -1 || echo "installed")"
          echo "OpenSSL:   $(openssl version)"
          echo "Jq:        $(jq --version)"
          echo "Bandwhich: $(bandwhich --version)"
          echo "Aria2:     $(aria2c --version | head -1)"
          echo "Sshtui:   $(sshtui --version)"
          echo "Proxytui: $(proxytui -version)"
          ${commonVersions}
      '';

      ai = mkShell "ai" ([]
        ++ lspPython
      ) hxCompletions ''
          ${commonVersions}
      '';
    };
  };
}
