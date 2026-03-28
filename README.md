# Isolated Development Environment for macOS

Nix-based dev shells on a dedicated encrypted APFS volume. All tools, caches, configs, and data stay off `~/` and `~/Library/`.

## Step 1 — Install Nix

```bash
curl -L https://nixos.org/nix/install | sh
```

Follow the prompts. This installs the Nix package manager and the nix daemon.

Restart your terminal after installation.

## Step 2 — Configure Nix

Edit `/etc/nix/nix.conf` (or create `~/.config/nix/nix.conf`):

```
experimental-features = nix-command flakes
trusted-users = root <your-username>
auto-optimise-store = true
```

Replace `<your-username>` with your macOS username.

Restart the daemon:

```bash
sudo launchctl stop org.nixos.nix-daemon
sudo launchctl start org.nixos.nix-daemon
```

## Step 3 — Create an encrypted APFS volume

Open Disk Utility or use the CLI. First, find your APFS container:

```bash
diskutil list
```

Look for your main APFS container (e.g. `disk5`). Then create the volume:

```bash
diskutil apfs addVolume disk5 APFS "studiowebux" -passphrase
```

You'll be prompted to set a password. The volume mounts at `/Volumes/studiowebux`.

## Step 4 — Clone this repo

```bash
mkdir -p "/Volumes/studiowebux/Development"
cd "/Volumes/studiowebux/Development"
git init
```

Copy all files from this repo into the directory, or clone it if hosted:

```bash
git clone <repo-url> "/Volumes/studiowebux/Development"
```

## Step 5 — Set up git config

Create a portable `.gitconfig` that stays on the volume:

```bash
cat > "/Volumes/studiowebux/Development/.gitconfig" << 'EOF'
[user]
    name = Your Name
    email = your@email.com
EOF
```

## Step 6 — Update the `devDir` path (if different)

If your volume is named differently, edit `flake.nix` line 14:

```nix
devDir = "/Volumes/Studio\\ Webux/Development";
```

Change it to match your volume path. The `\\` is a Nix-escaped backslash for the shell space.

## Step 7 — Build and enter a shell

```bash
cd "/Volumes/studiowebux/Development"
make hx
```

The first run downloads and builds everything — this takes a while. Subsequent runs are instant thanks to `--profile` caching.

## Available shells

| Command    | Purpose                                           |
|------------|---------------------------------------------------|
| `make all` | Everything (default shell, used to test the build)|
| `make hx`  | General editing — all LSPs                        |
| `make deno`| Deno/TypeScript development                       |
| `make go`  | Go development                                    |
| `make ops` | Infrastructure — terraform, kubectl, flux, helm, ansible |
| `make game`| Game dev — C# (omnisharp), Odin (ols), Lua        |
| `make ai`  | AI/ML — Python (pyright, ruff)                    |
| `make net` | Network analysis — nmap, mtr, tcpdump, etc.       |

## Maintenance

```bash
make update    # Update all flake inputs (nixpkgs)
make gc        # Garbage collect old nix store paths
make optimise  # Deduplicate identical files in the store
make show      # Show available shells
make check     # Validate the flake
```

## Regenerate completions

Zsh completions are cached per shell. To force regeneration:

```bash
rm -rf .cache/zsh-completions/
```

## How it works

- **No home directory pollution** — all XDG dirs, caches, history, and tool configs are redirected to the volume via env vars in `flake.nix`
- **Telemetry disabled** — every known telemetry env var is set to off
- **Pinned versions** — tools are fetched as specific versions in `pkgs/*.nix` with locked hashes
- **Encrypted at rest** — the APFS volume is FileVault encrypted
- **Nix store is the only thing on the host** — `/nix/store` holds the immutable packages, everything else is on the volume

## File tree

```
/Volumes/studiowebux/Development/
├── .cache/                  # Completions, go-build, npm, helm, ruff
├── .claude/                 # Claude Code config
├── .config/                 # XDG config (helix, go, helm)
├── .data/                   # XDG data (helm)
├── .state/                  # XDG state
├── .deno/                   # Deno cache
├── .dev-profiles/           # Nix dev shell profile cache
├── .git/
├── .gitconfig               # Portable git config
├── .kube/                   # Kubernetes config + cache
├── .terraform/              # Terraform data, plugins, logs
├── .ansible/                # Ansible home
├── .omnisharp/              # OmniSharp config
├── .zsh_history             # Shell history (shared across shells)
├── cerveau/                 # Cerveau app data
├── go/                      # GOPATH
├── gomodcache/              # Go module cache
├── pkgs/                    # Nix package definitions (one per tool)
├── flake.nix                # Shell definitions + env vars
├── flake.lock               # Pinned nixpkgs revision
└── Makefile                 # Shell entry points + maintenance
```

## Customizing

The `pkgs/` directory contains my own tools (cerveau, sshtui, restcli, etc.) — you don't need them. Remove what you don't use and add your own. Creating a package is straightforward: copy any existing `pkgs/*.nix` file, change the URL/version/hash, and wire it into `flake.nix`. The whole point is to make it yours.

You can also use packages directly from the official nixpkgs repository instead of writing custom derivations. Search available packages at [search.nixos.org](https://search.nixos.org/packages) and add them as `pkgs.<package-name>` in your shell definition. For example, `pkgs.jq`, `pkgs.git`, `pkgs.yaml-language-server` are all from nixpkgs. Custom `pkgs/*.nix` files are only needed when you want a specific version or a binary not available in nixpkgs.

## Updating a tool version

1. Find the new release URL for darwin arm64
2. Get the hash: `nix-prefetch-url [--unpack] <url>`
3. Convert: `nix hash to-sri --type sha256 <hash>`
4. Update the version and hash in `pkgs/<tool>.nix`
5. Clear the completion cache if applicable
6. Run `make <shell>` to verify
