# Litish

**Lite-ish** — a development environment that aims to be lightweight but still packs everything you need. Isolated, reproducible, and entirely off your home directory.

## Why

macOS dev tools scatter configs, caches, and state across `~/`, `~/Library/`, and beyond.

Litish puts everything on a dedicated encrypted APFS volume managed by Nix. Nothing touches your home directory. Every tool is pinned. Every telemetry flag is killed. You get reproducible shells you can enter from anywhere with a single command.

## Prerequisites

Install [Nix](https://nixos.org/download):

```bash
curl -L https://nixos.org/nix/install | sh
```

Add to `/etc/nix/nix.conf` (or `~/.config/nix/nix.conf`):

```
experimental-features = nix-command flakes
trusted-users = root <your-username>
auto-optimise-store = true
```

Restart the daemon:

```bash
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon
```

## Setup

Run the install script — it handles everything: volume creation, cloning, path patching, and git config.

```bash
curl -fsSL https://raw.githubusercontent.com/studiowebux/litish/main/install.sh | bash
```

Or clone first and run locally:

```bash
git clone https://github.com/studiowebux/litish.git
bash litish/install.sh
```

### Options

#### `--volume NAME`
The name of the APFS volume to create. This becomes the mount point at `/Volumes/NAME` and is used as the root for all dev directories. Defaults to `studiowebux`.

```bash
bash install.sh --volume mydev
# Creates /Volumes/mydev and uses it for everything
```

#### `--disk diskN`
The APFS container disk to add the volume to (e.g. `disk3`). The script auto-detects this in most cases — only needed if auto-detection picks the wrong disk or you have multiple APFS containers.

```bash
# Find your disk:
diskutil list

bash install.sh --disk disk3
```

#### `--no-volume`
Skip volume creation entirely. Use this if the volume already exists and is mounted (e.g. after a reboot where you manually unlocked it).

```bash
bash install.sh --no-volume
```

#### `--git-name` and `--git-email`
Your git identity, written to a `.gitconfig` on the volume so git works correctly inside every shell without touching your home directory. If omitted, the script will prompt you interactively.

```bash
bash install.sh --git-name "Jane Doe" --git-email "jane@example.com"
```

### Full example

```bash
bash install.sh \
  --volume mydev \
  --disk disk3 \
  --git-name "Jane Doe" \
  --git-email "jane@example.com"
```

All paths in `flake.nix` and the `litish` script are automatically patched to match the chosen volume name. No manual edits required.

## Usage

From anywhere:

```bash
litish          # Enter default shell (everything)
litish go       # Go development
litish deno     # Deno/TypeScript
litish hx       # General editing with all LSPs
litish ops      # Infrastructure — terraform, kubectl, flux, helm, ansible
litish game     # Game dev — C#, Odin, Lua
litish ai       # AI/ML — Python with pyright and ruff
litish node     # NodeJS
litish hw       # Linux tools
litish db       # Postgres, Mongo, redis
litish net      # Network analysis — nmap, mtr, tcpdump, etc.
litish update   # Update flake inputs
litish show     # Show available shells
litish check    # Validate the flake
litish gc       # Garbage collect old nix store paths
```

The first run downloads and builds everything. Subsequent runs are instant thanks to `--profile` caching.

## Shells

| Shell  | Purpose               | Key tools                                                                                       |
| ------ | --------------------- | ----------------------------------------------------------------------------------------------- |
| `all`  | Everything (default)  | All tools below combined                                                                        |
| `hx`   | General editing       | Helix + all LSP servers                                                                         |
| `deno` | TypeScript/JavaScript | Deno, TypeScript LSP                                                                            |
| `go`   | Go development        | Go, gopls, staticcheck, gosec, govulncheck                                                      |
| `ops`  | Infrastructure        | Terraform, kubectl, cilium, hubble, kubeseal, kustomize, k9s, flux, helm, ansible, sshtui, postgresql, mongodb-tools, mongosh, redis, podman, podman-compose, awscli2 |
| `game` | Game development      | OmniSharp (C#), ols (Odin), lua-language-server                                                 |
| `ai`   | AI/ML                 | Python 3, pyright, ruff                                                                         |
| `python` | Multi-version Python | Python 3.10, 3.11, 3.12                                                                       |
| `net`  | Network analysis      | nmap, mtr, socat, tcpdump, curl, wget, dig, whois, netcat-gnu, openssl, bandwhich, aria2, wireguard-tools, sshtui, proxytui |
| `node` | NodeJS Development    | nodejs_24, typescript-language-server                                                           |
| `hw`   | Hardware Analysis     | smartmontools                                                                                   |
| `db`   | Database              | postgresql, mongodb-tools, mongosh, redis                                                       |

## Packages

### Custom packages (`pkgs/`)

| Package                                                             | Version     | Description                           |
| ------------------------------------------------------------------- | ----------- | ------------------------------------- |
| [bujotui](https://github.com/studiowebux/bujotui)                   | 0.2.1       | Bullet journal TUI                    |
| [bujotui-mcp](https://github.com/studiowebux/bujotui)               | 0.2.1       | Bullet journal TUI MCP server         |
| [cerveau](https://github.com/studiowebux/cerveau.dev)               | 1.4.3       | Brain manager for Claude Code         |
| [cilium-cli](https://github.com/cilium/cilium-cli)                  | 0.19.2      | Cilium CLI                            |
| [hubble](https://github.com/cilium/hubble)                          | 1.18.6      | Cilium network observability          |
| [kubeseal](https://github.com/bitnami-labs/sealed-secrets)          | 0.36.6      | Sealed Secrets CLI                    |
| [kustomize](https://github.com/kubernetes-sigs/kustomize)           | 5.8.1       | Kubernetes configuration management   |
| [claude](https://claude.ai/code)                                    | 2.1.141     | Claude Code CLI                       |
| [deno](https://deno.land)                                           | 2.7.7       | JavaScript/TypeScript runtime         |
| [flux](https://fluxcd.io)                                           | 2.8.3       | GitOps for Kubernetes                 |
| [gh](https://cli.github.com)                                        | 2.88.1      | GitHub CLI                            |
| [go](https://go.dev)                                                | 1.26.1      | Go programming language               |
| [gopls](https://pkg.go.dev/golang.org/x/tools/gopls)                | 0.21.1      | Go language server                    |
| [helix](https://helix-editor.com)                                   | 25.07.1     | Terminal text editor                  |
| [helm](https://helm.sh)                                             | 4.1.3       | Kubernetes package manager            |
| [helm-ls](https://github.com/mrjosh/helm-ls)                        | 0.5.4       | Helm language server                  |
| [kubectl](https://kubernetes.io/docs/reference/kubectl)             | 1.35.3      | Kubernetes CLI                        |
| [lspmcp](https://github.com/studiowebux/lspmcp)                     | 0.1.0       | LSP to MCP bridge                     |
| [lua-language-server](https://github.com/LuaLS/lua-language-server) | 3.17.1      | Lua language server                   |
| [minimaldoc](https://github.com/studiowebux/minimaldoc)             | 1.6.0       | Documentation generator               |
| [ols](https://github.com/DanielGaworworski/ols)                     | dev-2026-03 | Odin language server                  |
| [omnisharp](https://github.com/OmniSharp/omnisharp-roslyn)          | 1.39.15     | C# language server                    |
| [proxytui](https://github.com/studiowebux/proxytui)                 | 0.2.0       | TUI proxy manager                     |
| [restcli](https://github.com/studiowebux/restcli)                   | 0.0.41      | REST API client TUI                   |
| [sshtui](https://github.com/studiowebux/sshtui)                     | 0.0.3       | SSH connection manager TUI            |
| [terraform](https://www.terraform.io)                               | 1.14.8      | Infrastructure as code                |
| [terraform-ls](https://github.com/hashicorp/terraform-ls)           | 0.38.6      | Terraform language server             |
| [timeago](https://github.com/studiowebux/timeago)                   | 1.0.2       | Timestamp converter                   |

### From nixpkgs

**Common (all shells):** git, zsh, jq, fd, ripgrep, fzf, lazygit, yq-go, python3, neovim

**LSP / formatters:** nil (Nix LSP), yaml-language-server, bash-language-server, prettier, vscode-langservers-extracted (JSON/HTML/CSS LSP), typescript-language-server, pyright, ruff, dockerfile-language-server

**Ops shells:** ansible, k9s, postgresql, mongodb-tools, mongosh, redis, podman, podman-compose, awscli2

**Network (`net` shell):** nmap, mtr, socat, tcpdump, curl, wget, dig, whois, netcat-gnu, openssl, bandwhich, aria2, wireguard-tools

**Shell-specific:** nodejs_24 (`node`), smartmontools (`hw`)

## How it works

- **No home directory pollution** — all XDG dirs, caches, history, and tool configs are redirected to the volume
- **Telemetry disabled** — every known telemetry env var is set to off
- **Pinned versions** — tools are fetched as specific versions in `pkgs/*.nix` with locked hashes
- **Encrypted at rest** — the APFS volume is FileVault encrypted
- **Nix store is the only thing on the host** — `/nix/store` holds the immutable packages, everything else is on the volume
- **Run from anywhere** — the `litish` CLI wraps `nix develop`, no need to `cd` anywhere

## Updating a tool version

1. Find the new release URL for darwin-arm64
2. Get the hash: `nix-prefetch-url [--unpack] <url>`
3. Convert: `nix hash to-sri --type sha256 <hash>`
4. Update version and hash in `pkgs/<tool>.nix`
5. Push to GitHub
6. Run `litish <shell>` to verify

## Regenerate completions

```bash
rm -rf /Volumes/studiowebux/Development/.cache/zsh-completions/
```

## Related projects

- [cerveau](https://github.com/studiowebux/cerveau.dev) — Brain manager for Claude Code
- [lspmcp](https://github.com/studiowebux/lspmcp) — LSP to MCP bridge server
- [sshtui](https://github.com/studiowebux/sshtui) — SSH connection manager TUI
- [proxytui](https://github.com/studiowebux/proxytui) — TUI proxy manager
- [restcli](https://github.com/studiowebux/restcli) — REST API client TUI
- [minimaldoc](https://github.com/studiowebux/minimaldoc) — Documentation generator
- [timeago](https://github.com/studiowebux/timeago) — Timestamp converter

## Contributing

Contributions are welcome. Open an issue or submit a pull request.

## Links

- [Website](https://studiowebux.com)
- [Discord](https://discord.gg/BG5Erm9fNv)
- [GitHub](https://github.com/studiowebux)

## Funding

- [GitHub Sponsors](https://github.com/sponsors/studiowebux)
- [Patreon](https://patreon.com/studiowebux)
- [Buy Me a Coffee](https://buymeacoffee.com/studiowebux)

## License

[MIT](LICENSE)
