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

## Step 4 — Set up the volume

```bash
mkdir -p "/Volumes/studiowebux/Development"
```

## Step 5 — Install the `litish` CLI

Copy the wrapper script to somewhere on your PATH:

```bash
cp litish /usr/local/bin/litish
# or
cp litish /Volumes/studiowebux/Development/.local/bin/litish
export PATH="/Volumes/studiowebux/Development/.local/bin:$PATH"
```

Make sure it's executable:

```bash
chmod +x /usr/local/bin/litish
```

## Step 6 — Set up git config

Create a portable `.gitconfig` that stays on the volume:

```bash
cat > "/Volumes/studiowebux/Development/.gitconfig" << 'EOF'
[user]
    name = Your Name
    email = your@email.com
EOF
```

## Step 7 — Update the `devDir` path (if different)

If your volume is named differently, edit `flake.nix` line 14:

```nix
devDir = "/Volumes/Studio\\ Webux/Development";
```

Change it to match your volume path. The `\\` is a Nix-escaped backslash for the shell space.

## Step 8 — Enter a shell

From anywhere:

```bash
litish go
```

The first run downloads and builds everything — this takes a while. Subsequent runs are instant thanks to `--profile` caching.

## Usage

```bash
litish          # Enter default shell (everything)
litish go       # Go development
litish deno     # Deno/TypeScript
litish hx       # General editing — all LSPs
litish ops      # Infrastructure — terraform, kubectl, flux, helm, ansible
litish game     # Game dev — C# (omnisharp), Odin (ols), Lua
litish ai       # AI/ML — Python (pyright, ruff)
litish net      # Network analysis — nmap, mtr, tcpdump, etc.
litish update   # Update flake inputs (nixpkgs)
litish show     # Show available shells
litish check    # Validate the flake
litish gc       # Garbage collect old nix store paths
```

Or use the Makefile directly (from the repo or Development directory):

```bash
make go
```

## Regenerate completions

Zsh completions are cached per shell. To force regeneration:

```bash
rm -rf /Volumes/studiowebux/Development/.cache/zsh-completions/
```

## How it works

- **No home directory pollution** — all XDG dirs, caches, history, and tool configs are redirected to the volume via env vars in `flake.nix`
- **Telemetry disabled** — every known telemetry env var is set to off
- **Pinned versions** — tools are fetched as specific versions in `pkgs/*.nix` with locked hashes
- **Encrypted at rest** — the APFS volume is FileVault encrypted
- **Nix store is the only thing on the host** — `/nix/store` holds the immutable packages, everything else is on the volume
- **Run from anywhere** — the `litish` CLI wraps `nix develop` so you don't need to be in any specific directory

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
├── .gitconfig               # Portable git config
├── .kube/                   # Kubernetes config + cache
├── .terraform/              # Terraform data, plugins, logs
├── .ansible/                # Ansible home
├── .omnisharp/              # OmniSharp config
├── .zsh_history             # Shell history (shared across shells)
├── cerveau/                 # Cerveau app data
├── go/                      # GOPATH
└── gomodcache/              # Go module cache
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
6. Run `litish <shell>` to verify
