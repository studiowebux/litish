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

      commonVersions = ''
        echo "Helix:   $(hx --version)"
        echo "Git:     $(git --version)"
        echo "Cerveau: $(cerveau version)"
        echo "Claude:  $(claude --version)"
        echo "Lspmcp:  $(lspmcp -version)"
        echo "Bujotui: $(bujotui version)"
        echo "Restcli:     $(restcli --version)"
        echo "Tea:         $(tea --version)"
        echo "Woodpecker:  $(woodpecker-cli --version)"
        echo "Python:      $(python3 --version)"
        echo "Pg_format:   $(pg_format --version 2>&1 | head -1)"
        echo "Tmux:        $(tmux -V)"
      '';

      mkPrompt = name: completions: ''
        export SHELL=${pkgs.zsh}/bin/zsh
        # $$ (this shell's PID) guarantees a unique dir even when TMPDIR
        # itself is reused across separate `nix develop` invocations
        # (observed with the macOS single-user nix-daemon build slot).
        export ZDOTDIR="''${TMPDIR:-/tmp}/litish-zdotdir-$$"
        rm -rf "$ZDOTDIR"
        mkdir -p "$ZDOTDIR"

        cat > $ZDOTDIR/.zshrc << 'EOF'
        # Clean up this shell's own ZDOTDIR when it exits, so
        # litish-zdotdir-* dirs don't pile up in TMPDIR.
        trap 'rm -rf "$ZDOTDIR"' EXIT

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

              echo "Deno:      $(deno --version | head -1)"
              echo "Go:        $(go version)"
              echo "Gopls:     $(gopls version)"
              echo "Terraform: $(terraform version | head -1)"
              echo "Kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
              echo "Hubble: $(hubble version)"
              echo "Flux: $(flux --version)"
              echo "Helm: $(helm version --short)"
              echo "Ansible:    $(ansible --version | head -1)"
              echo "Sshtui:     $(sshtui --version)"
              echo "Minimaldoc: $(minimaldoc --version)"
              echo "Proxytui:   $(proxytui -version)"
              echo "Mongodump:  $(mongodump --version 2>&1 | head -1)"
              echo "Mongosh:    $(mongosh --version)"
              echo "Redis-cli:  $(redis-cli --version)"
              echo "Psql:           $(psql --version)"
              echo "Podman:         $(podman --version)"
              echo "Podman-compose: $(podman-compose -v)"
              echo "Spacetime:      $(spacetime version)"
              echo "Odin:           $(odin version)"
              echo "K9s:            $(k9s version --short)"
              echo "AWS CLI:        $(aws --version)"
              echo "Python 3.10:    $(python3.10 --version)"
              echo "Python 3.11:    $(python3.11 --version)"
              echo "Python 3.12:    $(python3.12 --version)"
              echo "Dos2unix:       $(dos2unix --version 2>&1 | head -1)"
              echo "Wg:             $(wg --version)"
              echo "Smartctl:       $(smartctl --version | head -1)"
              echo "Node:           $(node --version)"
              echo "Dotnet:         $(dotnet --version)"
              echo "Rustc:          $(rustc --version)"
              echo "Cargo:          $(cargo --version)"
              echo "Rust-analyzer:  $(rust-analyzer --version)"
              echo "Clippy:         $(cargo-clippy --version)"
              echo "Rustfmt:        $(rustfmt --version)"

              mkdir -p ${devDir}/.config/aws

              ${commonVersions}
            '';

        hx =
          mkShell "hx" ([ ] ++ lspTs ++ lspPython ++ lspOps ++ lspOdin ++ lspCsharp ++ lspLua) hxCompletions
            ''
              ${commonVersions}
            '';

        deno = mkShell "deno" ([ deno spacetimedb ] ++ lspTs) denoCompletions ''
          echo "Deno:      $(deno --version)"
          echo "Spacetime: $(spacetime version)"
          ${commonVersions}
        '';

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

          echo "Staticcheck: $(staticcheck --version)"
          echo "Gosec:       $(gosec --version)"
          echo "Govulncheck: $(govulncheck --version)"

          echo "Go:    $(go version)"
          echo "Gopls: $(gopls version)"
          echo "Psql:  $(psql --version)"
          ${commonVersions}
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
              echo "Terraform: $(terraform version | head -1)"
              echo "Kubectl:   $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
              echo "Cilium:    $(cilium version)"
              echo "Hubble:    $(hubble version)"
              echo "Kubeseal:  $(kubeseal --version)"
              echo "Kustomize: $(kustomize version)"
              echo "K9s:       $(k9s version --short)"
              echo "Flux:      $(flux --version)"
              echo "Helm:      $(helm version --short)"
              echo "Ansible:   $(ansible --version | head -1)"
              echo "Sshtui:    $(sshtui --version)"
              echo "Mongodump: $(mongodump --version 2>&1 | head -1)"
              echo "Mongosh:        $(mongosh --version)"
              echo "Redis-cli:      $(redis-cli --version)"
              echo "Psql:           $(psql --version)"
              echo "Podman:         $(podman --version)"
              echo "Podman-compose: $(podman-compose -v)"
              echo "AWS CLI:        $(aws --version)"
              echo "Spacetime:      $(spacetime version)"

              ${commonVersions}
            '';

        game = mkShell "game" ([ odin ] ++ lspCsharp ++ lspOdin ++ lspLua) hxCompletions ''
          echo "Odin: $(odin version)"
          ${commonVersions}
        '';

        python =
          mkShell "python"
            ([
              pkgs.python310
              pkgs.python311
              pkgs.python312
            ])
            hxCompletions
            ''
              echo "Python 3.10: $(python3.10 --version)"
              echo "Python 3.11: $(python3.11 --version)"
              echo "Python 3.12: $(python3.12 --version)"
              ${commonVersions}
            '';

        keyboard =
          mkShell "keyboard"
            ([
              pkgs.qmk
              pkgs.dos2unix
            ])
            hxCompletions
            ''
              ${commonVersions}
            '';

        net =
          mkShell "net"
            [
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
            ]
            hxCompletions
            ''
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
              echo "Wg:        $(wg --version)"
              echo "Sshtui:   $(sshtui --version)"
              echo "Proxytui: $(proxytui -version)"
              ${commonVersions}
            '';

        ai = mkShell "ai" ([ pkgs.python3 ] ++ lspPython) hxCompletions ''
          echo "Python:  $(python3 --version)"
          ${commonVersions}
        '';

        hw = mkShell "hw" [ pkgs.smartmontools ] hxCompletions ''
          echo "Smartctl: $(smartctl --version | head -1)"
          ${commonVersions}
        '';

        db = mkShell "db" [ pkgs.redis pkgs.postgresql pkgs.mongodb-tools pkgs.mongosh spacetimedb ] hxCompletions ''
          echo "Redis-cli:   $(redis-cli --version)"
          echo "Psql:        $(psql --version)"
          echo "Mongodump:   $(mongodump --version 2>&1 | head -1)"
          echo "Mongosh:     $(mongosh --version)"
          echo "Spacetime:   $(spacetime version)"
          ${commonVersions}
        '';

        dotnet = mkShell "dotnet" ([ dotnet pkgs.icu ] ++ lspCsharp) hxCompletions ''
          export DOTNET_ROOT=${dotnet}
          export DOTNET_CLI_TELEMETRY_OPTOUT=1
          export DOTNET_NOLOGO=1
          export NUGET_PACKAGES=${devDir}/.nuget/packages
          export DOTNET_CLI_HOME=${devDir}
          export PATH=${devDir}/.dotnet/tools:$PATH
          mkdir -p ${devDir}/.nuget/packages ${devDir}/.dotnet/tools

          echo "Dotnet: $(dotnet --version)"
          echo "Note: MonoGame tooling (mgcb, project templates) isn't packaged in nixpkgs."
          echo "      Install once with: dotnet tool install --global dotnet-mgcb --version <x.y.z>"
          echo "                         dotnet new install MonoGame.Templates.CSharp::<x.y.z>"
          ${commonVersions}
        '';

        rust = mkShell "rust" (rustToolchain ++ lspRust) hxCompletions ''
          export CARGO_HOME=${devDir}/.cargo
          export PATH=${devDir}/.cargo/bin:$PATH
          mkdir -p ${devDir}/.cargo

          echo "Rustc:          $(rustc --version)"
          echo "Cargo:          $(cargo --version)"
          echo "Rust-analyzer:  $(rust-analyzer --version)"
          echo "Clippy:         $(cargo-clippy --version)"
          echo "Rustfmt:        $(rustfmt --version)"
          ${commonVersions}
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

          echo "Node: $(node --version)"
          echo "Npm:  $(npm --version)"
          ${commonVersions}
        '';
      };
    };
}
