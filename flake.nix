{
  description = "Isolated development environment — all tools, caches, and configs stay on a dedicated encrypted volume";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-darwin";

      pkgs = nixpkgs.legacyPackages.${system};

      # Resolved at runtime (not eval time) so the published GitHub flake honors
      # each user's volume via $LITISH_DEV_DIR, falling back to the default when
      # unset. The litish wrapper exports LITISH_DEV_DIR before `nix develop`.
      devDir = "\${LITISH_DEV_DIR:-/Volumes/studiowebux/Development}";

      deno = pkgs.callPackage ./pkgs/deno.nix { };
      helix = pkgs.callPackage ./pkgs/helix.nix { };
      gh = pkgs.callPackage ./pkgs/gh.nix { };
      gopls = pkgs.callPackage ./pkgs/gopls.nix { };
      go = pkgs.callPackage ./pkgs/go.nix { };
      cerveau = pkgs.callPackage ./pkgs/cerveau.nix { };
      claude = pkgs.callPackage ./pkgs/claude.nix { };
      kubectl = pkgs.callPackage ./pkgs/kubectl.nix { };
      cilium = pkgs.callPackage ./pkgs/cilium.nix { };
      hubble = pkgs.callPackage ./pkgs/hubble.nix { };
      kubeseal = pkgs.callPackage ./pkgs/kubeseal.nix { };
      kustomize = pkgs.callPackage ./pkgs/kustomize.nix { };
      flux = pkgs.callPackage ./pkgs/flux.nix { };
      helm = pkgs.callPackage ./pkgs/helm.nix { };
      terraform = pkgs.callPackage ./pkgs/terraform.nix { };

      # LSP servers
      lua-language-server = pkgs.callPackage ./pkgs/lua-language-server.nix { };
      terraform-ls = pkgs.callPackage ./pkgs/terraform-ls.nix { };
      helm-ls = pkgs.callPackage ./pkgs/helm-ls.nix { };
      ols = pkgs.callPackage ./pkgs/ols.nix { };
      omnisharp = pkgs.omnisharp-roslyn;
      dotnet = pkgs.dotnetCorePackages.combinePackages [
        pkgs.dotnetCorePackages.sdk_10_0-bin
        pkgs.dotnetCorePackages.aspnetcore_10_0-bin
      ];
      sshtui = pkgs.callPackage ./pkgs/sshtui.nix { };
      minimaldoc = pkgs.callPackage ./pkgs/minimaldoc.nix { };
      restcli = pkgs.callPackage ./pkgs/restcli.nix { };
      proxytui = pkgs.callPackage ./pkgs/proxytui.nix { };
      timeago = pkgs.callPackage ./pkgs/timeago.nix { };
      lspmcp = pkgs.callPackage ./pkgs/lspmcp.nix { };
      bujotui = pkgs.callPackage ./pkgs/bujotui.nix { };
      bujotui-mcp = pkgs.callPackage ./pkgs/bujotui-mcp.nix { };
      spacetimedb = pkgs.callPackage ./pkgs/spacetimedb.nix { };
      tea = pkgs.callPackage ./pkgs/tea.nix { };
      woodpecker-cli = pkgs.callPackage ./pkgs/woodpecker-cli.nix { };
      odin = pkgs.callPackage ./pkgs/odin.nix { };

      commonPackages = [
        helix
        pkgs.neovim
        pkgs.fd
        pkgs.ripgrep
        pkgs.fzf
        pkgs.lazygit
        pkgs.tmux
        pkgs.yq-go
        gh
        tea
        woodpecker-cli
        pkgs.git
        pkgs.zsh
        pkgs.nil # nix lsp
        pkgs.yaml-language-server # yaml lsp
        pkgs.nodePackages.bash-language-server # bash lsp
        pkgs.nodePackages.prettier # formatter
        pkgs.pgformatter # sql formatter (pg_format)
        pkgs.vscode-langservers-extracted # json, html, css lsp
        pkgs.taplo # toml lsp + formatter
        pkgs.jq
        pkgs.lldb
        restcli
        timeago
        bujotui
        bujotui-mcp
        cerveau
        claude
        pkgs.python3
        lspmcp
      ];

      # Specialized LSP groups
      lspTs = [ pkgs.nodePackages.typescript-language-server ];
      lspPython = [
        pkgs.pyright
        pkgs.ruff
      ];
      lspOps = [
        terraform-ls
        helm-ls
        pkgs.dockerfile-language-server
      ];
      lspOdin = [ ols ];
      lspCsharp = [ omnisharp ];
      lspRust = [
        pkgs.rust-analyzer
        pkgs.clippy
        pkgs.rustfmt
      ];
      rustToolchain = [
        pkgs.cargo
        pkgs.rustc
      ];
      lspLua = [ lua-language-server ];

      cerveauCompletion = "cerveau completion zsh > $COMP_DIR/_cerveau";
      ghCompletion = "gh completion -s zsh > $COMP_DIR/_gh";
      # tea has no built-in completion generator; it's an urfave/cli app like
      # woodpecker-cli, so drive its generic --generate-shell-completion flag.
      teaCompletion = ''
        cat > $COMP_DIR/_tea << 'TEA_COMPLETION_EOF'
        #compdef tea
        compdef _tea tea

        _tea() {
        	local -a opts
        	local current
        	current=''${words[-1]}
        	if [[ "$current" == "-"* ]]; then
        		opts=("''${(@f)$(''${words[@]:0:#words[@]-1} ''${current} --generate-shell-completion)}")
        	else
        		opts=("''${(@f)$(''${words[@]:0:#words[@]-1} --generate-shell-completion)}")
        	fi

        	if [[ "''${opts[1]}" != "" ]]; then
        		_describe 'values' opts
        	else
        		_files
        	fi
        }

        if [ "$funcstack[1]" = "_tea" ]; then
        	_tea
        fi
        TEA_COMPLETION_EOF
      '';
      # woodpecker-cli's `completion zsh` output is broken upstream: it prints
      # a script that calls `--generate-shell-completion`, but the app never
      # sets EnableShellCompletion, so that flag isn't registered and every
      # tab-press fails with "flag provided but not defined". Dropped until
      # upstream fixes it (see cmd/cli/app.go in woodpecker-ci/woodpecker).
      denoCompletion = "deno completions zsh > $COMP_DIR/_deno";
      kubectlCompletion = "kubectl completion zsh > $COMP_DIR/_kubectl";
      ciliumCompletion = "cilium completion zsh > $COMP_DIR/_cilium";
      hubbleCompletion = "hubble completion zsh > $COMP_DIR/_hubble";
      # kubeseal is a plain flag-based binary with no completion generator.
      kustomizeCompletion = "kustomize completion zsh > $COMP_DIR/_kustomize";
      fluxCompletion = "flux completion zsh > $COMP_DIR/_flux";
      helmCompletion = "helm completion zsh > $COMP_DIR/_helm";
      terraformCompletion = ''printf '#compdef terraform\nautoload -U +X bashcompinit && bashcompinit\ncomplete -o nospace -C terraform terraform\n' > $COMP_DIR/_terraform'';
      awsCompletion = ''printf '#compdef aws\nautoload -U +X bashcompinit && bashcompinit\ncomplete -C aws_completer aws\n' > $COMP_DIR/_aws'';

      nodeCompletion = "npm completion > $COMP_DIR/_npm";

      nodeCompletions = ''
        ${ghCompletion}
        ${teaCompletion}
        ${cerveauCompletion}
        ${nodeCompletion}
      '';

      denoCompletions = ''
        ${ghCompletion}
        ${teaCompletion}
        ${denoCompletion}
        ${cerveauCompletion}
      '';

      goCompletions = ''
        ${ghCompletion}
        ${teaCompletion}
        ${cerveauCompletion}
      '';

      hxCompletions = ''
        ${ghCompletion}
        ${teaCompletion}
        ${cerveauCompletion}
      '';

      opsCompletions = ''
        ${ghCompletion}
        ${teaCompletion}
        ${cerveauCompletion}
        ${denoCompletion}
        ${kubectlCompletion}
        ${ciliumCompletion}
        ${hubbleCompletion}
        ${kustomizeCompletion}
        ${fluxCompletion}
        ${helmCompletion}
        ${terraformCompletion}
        ${awsCompletion}
      '';

      mkPrompt = name: completions: ''
        export SHELL=${pkgs.zsh}/bin/zsh
        # Shared per-environment (not per-PID): concurrent shells for the same
        # environment reuse this dir, so macOS Terminal/iTerm's own exit hook
        # (which writes session state under $ZDOTDIR/.zsh_sessions) never
        # races against a delete-on-exit trap.
        export ZDOTDIR="''${TMPDIR:-/tmp}/litish-zdotdir-${name}"
        mkdir -p "$ZDOTDIR"

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

        # AWS CLI
        export AWS_CONFIG_FILE=${devDir}/.config/aws/config
        export AWS_SHARED_CREDENTIALS_FILE=${devDir}/.config/aws/credentials

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
        export AWS_CLI_AUTO_PROMPT=off
        export CHECKPOINT_DISABLE=1
        export ANSIBLE_NOCOWS=1
        export ANSIBLE_NO_LOG=0
        export FLUX_NO_TELEMETRY=1
        export HELM_NO_UPDATE_NOTIFIER=1
        export CERVEAU_SKIP_BINARY_UPDATE=1

        # Xcode CLI tools (system-provided, not reproducible)
        export PATH="$(xcode-select -p)/usr/bin:$PATH"

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

      mkShell =
        name: packages: completions: extra:
        pkgs.mkShell {
          packages = commonPackages ++ packages;
          shellHook = ''
            ${extra}
          ''
          + mkPrompt name completions;
        };

    in
    {

      devShells.${system} = {
        default =
          mkShell "all"
            (
              [
                deno
                go
                gopls
                kubectl
                cilium
                hubble
                kubeseal
                kustomize
                flux
                helm
                terraform
                pkgs.ansible
                sshtui
                minimaldoc
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
                pkgs.bandwhich
                pkgs.aria2
                pkgs.mongodb-tools
                pkgs.mongosh
                pkgs.redis
                pkgs.postgresql
                pkgs.podman-compose
                pkgs.podman
                spacetimedb
                odin
                pkgs.k9s
                pkgs.awscli2
                pkgs.python310
                pkgs.python311
                pkgs.python312
                pkgs.qmk
                pkgs.dos2unix
                pkgs.wireguard-tools
                pkgs.smartmontools
                pkgs.nodejs_24
                dotnet
                pkgs.icu
                pkgs.emscripten
              ]
              ++ lspTs
              ++ lspPython
              ++ lspOps
              ++ lspOdin
              ++ lspCsharp
              ++ lspLua
              ++ lspRust
              ++ rustToolchain
            )
            opsCompletions
            ''
              export GOROOT=${go}
              export GOPATH=${devDir}/go
              export GOCACHE=${devDir}/.cache/go-build
              export PATH=${go}/bin:$GOPATH/bin:$PATH
              mkdir -p ${devDir}/.kube
              mkdir -p ${devDir}/.terraform/plugin-cache

              export DOTNET_ROOT=${dotnet}
              export DOTNET_CLI_TELEMETRY_OPTOUT=1
              export DOTNET_NOLOGO=1
              export NUGET_PACKAGES=${devDir}/.nuget/packages
              export DOTNET_CLI_HOME=${devDir}
              export PATH=${devDir}/.dotnet/tools:$PATH
              mkdir -p ${devDir}/.nuget/packages ${devDir}/.dotnet/tools

              export CARGO_HOME=${devDir}/.cargo
              export PATH=${devDir}/.cargo/bin:$PATH
              mkdir -p ${devDir}/.cargo

              mkdir -p ${devDir}/.config/aws
            '';

        hx = mkShell "hx" (
          [ ] ++ lspTs ++ lspPython ++ lspOps ++ lspOdin ++ lspCsharp ++ lspLua
        ) hxCompletions "";

        deno = mkShell "deno" (
          [
            deno
            spacetimedb
          ]
          ++ lspTs
        ) denoCompletions "";

        go = mkShell "go" [ go gopls pkgs.postgresql ] goCompletions ''
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
        '';
        ops =
          mkShell "ops"
            (
              [
                kubectl
                cilium
                hubble
                kubeseal
                kustomize
                flux
                helm
                terraform
                pkgs.k9s
                pkgs.ansible
                sshtui
                pkgs.mongodb-tools
                pkgs.mongosh
                pkgs.redis
                pkgs.postgresql
                pkgs.podman-compose
                pkgs.podman
                pkgs.awscli2
                spacetimedb
              ]
              ++ lspOps
            )
            opsCompletions
            ''
              mkdir -p ${devDir}/.kube
              mkdir -p ${devDir}/.terraform/plugin-cache
              mkdir -p ${devDir}/.config/aws
            '';

        game = mkShell "game" (
          [
            odin
            pkgs.emscripten
          ]
          ++ lspCsharp
          ++ lspOdin
          ++ lspLua
        ) hxCompletions "";

        swift = mkShell "swift" [ ] hxCompletions ''
          # Xcode's Swift toolchain is proprietary and not packaged in
          # nixpkgs, so point straight at the system install rather than
          # relying on xcode-select (which can drift, e.g. onto nixpkgs'
          # apple-sdk stub).
          export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
          export PATH="$DEVELOPER_DIR/Toolchains/XcodeDefault.xctoolchain/usr/bin:$DEVELOPER_DIR/usr/bin:$PATH"
        '';

        python = mkShell "python" ([
          pkgs.python310
          pkgs.python311
          pkgs.python312
        ]) hxCompletions "";

        keyboard = mkShell "keyboard" ([
          pkgs.qmk
          pkgs.dos2unix
        ]) hxCompletions "";

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
          pkgs.wireguard-tools
        ] hxCompletions "";

        ai = mkShell "ai" ([ pkgs.python3 ] ++ lspPython) hxCompletions "";

        hw = mkShell "hw" [ pkgs.smartmontools ] hxCompletions "";

        db = mkShell "db" [
          pkgs.redis
          pkgs.postgresql
          pkgs.mongodb-tools
          pkgs.mongosh
          spacetimedb
        ] hxCompletions "";

        dotnet =
          mkShell "dotnet"
            (
              [
                dotnet
                pkgs.icu
              ]
              ++ lspCsharp
            )
            hxCompletions
            ''
              export DOTNET_ROOT=${dotnet}
              export DOTNET_CLI_TELEMETRY_OPTOUT=1
              export DOTNET_NOLOGO=1
              export NUGET_PACKAGES=${devDir}/.nuget/packages
              export DOTNET_CLI_HOME=${devDir}
              export PATH=${devDir}/.dotnet/tools:$PATH
              mkdir -p ${devDir}/.nuget/packages ${devDir}/.dotnet/tools
            '';

        rust = mkShell "rust" (rustToolchain ++ lspRust) hxCompletions ''
          export CARGO_HOME=${devDir}/.cargo
          export PATH=${devDir}/.cargo/bin:$PATH
          mkdir -p ${devDir}/.cargo
        '';

        node = mkShell "node" ([ pkgs.nodejs_24 ] ++ lspTs) nodeCompletions ''
          export NPM_CONFIG_CACHE=${devDir}/.cache/npm
          export NPM_CONFIG_PREFIX=${devDir}/.npm-global
          export NPM_CONFIG_USERCONFIG=${devDir}/.config/npm/npmrc
          export NODE_REPL_HISTORY=${devDir}/.node_repl_history
          export PATH=${devDir}/.npm-global/bin:$PATH

          # Telemetry
          export NPM_CONFIG_UPDATE_NOTIFIER=false
          export NPM_CONFIG_FUND=false
          export NEXT_TELEMETRY_DISABLED=1
          export ASTRO_TELEMETRY_DISABLED=1
          export NUXT_TELEMETRY_DISABLED=1
          export TURBO_TELEMETRY_DISABLED=1
        '';
      };
    };
}
