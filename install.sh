#!/usr/bin/env bash
# install.sh — first-boot setup for litish
# Usage: curl -fsSL https://raw.githubusercontent.com/studiowebux/litish/main/install.sh | bash
#   or:  bash install.sh [--volume NAME] [--disk disk5] [--no-volume]
set -euo pipefail

# ── Configuration ────────────────────────────────────────────────────────────

VOLUME_NAME="${LITISH_VOLUME:-studiowebux}"
APFS_DISK=""           # auto-detected if empty
SKIP_VOLUME=false
GIT_USER=""
GIT_EMAIL=""

# ── Argument parsing ──────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --volume)   VOLUME_NAME="$2"; shift 2 ;;
    --disk)     APFS_DISK="$2";   shift 2 ;;
    --no-volume) SKIP_VOLUME=true; shift ;;
    --git-name)  GIT_USER="$2";   shift 2 ;;
    --git-email) GIT_EMAIL="$2";  shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Derived paths (single source of truth) ───────────────────────────────────

VOLUME_PATH="/Volumes/${VOLUME_NAME}"
DEV_DIR="${VOLUME_PATH}/Development"
PROJECTS_DIR="${VOLUME_PATH}/Projects"
LITISH_DIR="${PROJECTS_DIR}/litish"
LITISH_BIN="/usr/local/bin/litish"
REPO="https://github.com/studiowebux/litish.git"

# ── Helpers ───────────────────────────────────────────────────────────────────

info()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok()    { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
die()   { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }
ask()   { printf '\033[1;36m  ?\033[0m %s: ' "$*"; }

# ── 1. Check prerequisites ────────────────────────────────────────────────────

info "Checking prerequisites"

if ! command -v nix &>/dev/null; then
  die "Nix is not installed. Install it first: curl -L https://nixos.org/nix/install | sh"
fi
ok "Nix $(nix --version)"

if ! command -v git &>/dev/null; then
  die "git is not installed"
fi
ok "git $(git --version)"

# Check nix flakes enabled
if ! nix flake --help &>/dev/null 2>&1; then
  warn "Nix flakes may not be enabled. Add to /etc/nix/nix.conf:"
  warn "  experimental-features = nix-command flakes"
fi

# ── 2. Create encrypted APFS volume ──────────────────────────────────────────

if [[ "$SKIP_VOLUME" == false ]]; then
  if [[ -d "$VOLUME_PATH" ]]; then
    ok "Volume already mounted at ${VOLUME_PATH}"
  else
    info "Creating encrypted APFS volume '${VOLUME_NAME}'"

    # Auto-detect APFS container if not specified
    if [[ -z "$APFS_DISK" ]]; then
      APFS_DISK=$(diskutil list | awk '/APFS Container/{print $NF}' | head -1)
      if [[ -z "$APFS_DISK" ]]; then
        die "Could not auto-detect APFS container. Pass --disk diskN (e.g. --disk disk3)"
      fi
      info "Auto-detected APFS container: ${APFS_DISK}"
    fi

    ask "Passphrase for volume '${VOLUME_NAME}'"
    read -rs PASSPHRASE
    echo
    ask "Confirm passphrase"
    read -rs PASSPHRASE2
    echo

    if [[ "$PASSPHRASE" != "$PASSPHRASE2" ]]; then
      die "Passphrases do not match"
    fi

    diskutil apfs addVolume "$APFS_DISK" APFS "$VOLUME_NAME" -passphrase "$PASSPHRASE"
    ok "Volume created at ${VOLUME_PATH}"

    # Mount it (diskutil addVolume mounts automatically, but confirm)
    if [[ ! -d "$VOLUME_PATH" ]]; then
      die "Volume was created but not mounted at ${VOLUME_PATH}"
    fi
  fi
else
  if [[ ! -d "$VOLUME_PATH" ]]; then
    die "Volume not found at ${VOLUME_PATH}. Mount it first or remove --no-volume."
  fi
  ok "Using existing volume at ${VOLUME_PATH}"
fi

# ── 3. Create directory structure ────────────────────────────────────────────

info "Creating directory structure"

dirs=(
  "${DEV_DIR}"
  "${DEV_DIR}/.claude"
  "${DEV_DIR}/.config"
  "${DEV_DIR}/.cache"
  "${DEV_DIR}/.data"
  "${DEV_DIR}/.state"
  "${DEV_DIR}/.deno"
  "${DEV_DIR}/.kube"
  "${DEV_DIR}/.ansible"
  "${DEV_DIR}/.npm-global"
  "${DEV_DIR}/.config/containers"
  "${DEV_DIR}/.config/bujotui"
  "${DEV_DIR}/.data/bujotui"
  "${DEV_DIR}/.cache/npm"
  "${DEV_DIR}/.terraform/plugin-cache"
  "${DEV_DIR}/.dev-profiles"
  "${PROJECTS_DIR}"
  "${VOLUME_PATH}/tmp"
)

for d in "${dirs[@]}"; do
  mkdir -p "$d"
done
ok "Directories created"

# ── 4. Clone litish repo ──────────────────────────────────────────────────────

info "Cloning litish"

if [[ -d "${LITISH_DIR}/.git" ]]; then
  ok "Repo already exists at ${LITISH_DIR} — pulling latest"
  git -C "$LITISH_DIR" pull --ff-only
else
  git clone "$REPO" "$LITISH_DIR"
  ok "Cloned to ${LITISH_DIR}"
fi

# ── 5. Sync volume name into flake.nix and litish script ─────────────────────

if [[ "$VOLUME_NAME" != "studiowebux" ]]; then
  info "Patching paths for volume name '${VOLUME_NAME}'"

  sed -i '' "s|/Volumes/studiowebux/Development|${DEV_DIR}|g" "${LITISH_DIR}/flake.nix"
  sed -i '' "s|/Volumes/studiowebux/Development|${DEV_DIR}|g" "${LITISH_DIR}/litish"
  ok "Paths updated in flake.nix and litish"
fi

# ── 6. Install litish binary ──────────────────────────────────────────────────

info "Installing litish CLI"

if [[ -f "$LITISH_BIN" ]] && cmp -s "${LITISH_DIR}/litish" "$LITISH_BIN"; then
  ok "litish already up to date at ${LITISH_BIN}"
else
  cp "${LITISH_DIR}/litish" "$LITISH_BIN"
  chmod +x "$LITISH_BIN"
  ok "Installed to ${LITISH_BIN}"
fi

# ── 7. Write .gitconfig ───────────────────────────────────────────────────────

GITCONFIG="${DEV_DIR}/.gitconfig"

if [[ -f "$GITCONFIG" ]]; then
  ok ".gitconfig already exists at ${GITCONFIG}"
else
  info "Setting up git config"

  if [[ -z "$GIT_USER" ]]; then
    ask "Git user name"
    read -r GIT_USER
  fi

  if [[ -z "$GIT_EMAIL" ]]; then
    ask "Git email"
    read -r GIT_EMAIL
  fi

  cat > "$GITCONFIG" <<EOF
[user]
    name = ${GIT_USER}
    email = ${GIT_EMAIL}
EOF
  ok ".gitconfig written"
fi

# ── 8. Write podman containers.conf ──────────────────────────────────────────

CONTAINERS_CONF="${DEV_DIR}/.config/containers/containers.conf"

if [[ ! -f "$CONTAINERS_CONF" ]]; then
  printf '[machine]\nrosetta = false\n' > "$CONTAINERS_CONF"
  ok "containers.conf written (rosetta = false)"
else
  ok "containers.conf already exists"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

echo
printf '\033[1;32mSetup complete.\033[0m\n'
echo
echo "  Volume:  ${VOLUME_PATH}"
echo "  Dev dir: ${DEV_DIR}"
echo "  Repo:    ${LITISH_DIR}"
echo "  CLI:     ${LITISH_BIN}"
echo
echo "Next steps:"
echo "  1. litish        — enter the default shell (downloads packages on first run)"
echo "  2. litish go     — Go shell"
echo "  3. litish ops    — Ops shell (terraform, kubectl, podman...)"
echo
echo "To set up podman (inside any nix shell):"
echo "  podman machine init && podman machine start"
