#!/usr/bin/env bash
# pkgs/bump.sh — bump a pinned tool in pkgs/<pkg>.nix to a given version
# Usage: pkgs/bump.sh <pkg> <version>
#   e.g. pkgs/bump.sh terraform 1.15.7
#        pkgs/bump.sh gopls 0.22.0
#
# Works for any pkgs/*.nix that pins a single `version = "...";` and one or
# more `hash = "...";` / `vendorHash = "...";` style fields. It fakes each
# hash, lets the build fail with a mismatch, reads the correct value out of
# Nix's error message, then verifies the real build produces the requested
# version. On ANY failure (or Ctrl-C) the file is restored untouched.
#
# macOS-safe: no GNU-only sed features; all edits go through perl.
# Pair with pkgs/check-updates.sh to see what needs bumping.
set -uo pipefail

PKG="${1:-}"
VERSION="${2:-}"
if [[ -z "$PKG" || -z "$VERSION" ]]; then
  echo "usage: $0 <pkg> <version>   (e.g. $0 terraform 1.15.7)" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_FILE="${SCRIPT_DIR}/${PKG}.nix"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)" || exit 1
FAKE_HASH="sha256-$(printf 'A%.0s' {1..43})="
HASH_FIELDS=(hash vendorHash cargoHash npmDepsHash sha256)

[[ -f "$NIX_FILE" ]] || { echo "error: $NIX_FILE not found" >&2; exit 1; }
command -v perl >/dev/null || { echo "error: perl is required" >&2; exit 1; }

BACKUP="$(mktemp)"
ERRFILE="$(mktemp)"
cp "$NIX_FILE" "$BACKUP"

# Restore the original file on any exit unless we finished successfully.
SUCCESS=0
cleanup() {
  if [[ "$SUCCESS" -ne 1 ]]; then
    cp "$BACKUP" "$NIX_FILE"
    echo "Restored ${NIX_FILE#"${REPO_ROOT}/"} (bump did not complete)." >&2
  fi
  rm -f "$BACKUP" "$ERRFILE"
}
trap cleanup EXIT
trap 'exit 130' INT TERM

# --- helpers ---------------------------------------------------------------

# Value of the first `field = "...";` line, or empty.
get_field() {
  grep -E "^[[:space:]]*$1[[:space:]]*=[[:space:]]*\"" "$NIX_FILE" | head -1 \
    | sed -E 's/.*"([^"]*)".*/\1/'
}

# Number of lines defining `field = "...";`.
count_field() {
  grep -cE "^[[:space:]]*$1[[:space:]]*=[[:space:]]*\"" "$NIX_FILE" || true
}

# Replace the value of the FIRST `field = "...";` line only (anchored to line
# start, so `goVersion =` or comments can't match).
set_field() {
  FIELD="$1" NEW="$2" perl -0pi -e \
    's/^(\s*\Q$ENV{FIELD}\E\s*=\s*)"[^"]*"/${1}"$ENV{NEW}"/m' "$NIX_FILE"
}

build_expr() {
  cat <<EOF
let
  flake = builtins.getFlake (toString ${REPO_ROOT});
  pkgs  = flake.inputs.nixpkgs.legacyPackages.\${builtins.currentSystem};
in pkgs.callPackage ${NIX_FILE} {}
EOF
}

# Runs the build. stdout (out paths) -> $BUILD_OUT, stderr -> $ERRFILE.
run_build() {
  BUILD_OUT="$(nix build --no-link --print-out-paths --impure \
    --expr "$(build_expr)" 2>"$ERRFILE")"
}

# Fake $field's hash, rebuild, and write back the value Nix reports.
# Returns 0 if a mismatch was found and fixed, 1 otherwise.
fix_hash_field() {
  local field="$1"
  local n
  n="$(count_field "$field")"
  [[ "$n" -ge 1 ]] || return 1
  if [[ "$n" -gt 1 ]]; then
    echo "error: ${field} appears ${n} times in ${PKG}.nix (per-platform hashes?)." >&2
    echo "       This script only handles one per field; update them by hand." >&2
    exit 1
  fi

  local snapshot
  snapshot="$(mktemp)"
  cp "$NIX_FILE" "$snapshot"
  set_field "$field" "$FAKE_HASH"

  run_build
  local got
  got="$(grep -E '^[[:space:]]*got:' "$ERRFILE" | head -1 | sed -E 's/.*got:[[:space:]]*//')"

  if [[ -z "$got" ]]; then
    cp "$snapshot" "$NIX_FILE"   # this field wasn't the problem; put it back
    rm -f "$snapshot"
    return 1
  fi

  rm -f "$snapshot"
  echo "  ${field}: ${got}"
  set_field "$field" "$got"
  return 0
}

# Try the usual version flags; print the first line of the first that works.
reported_version() {
  local bin="$1" flag out
  for flag in --version version -version -V; do
    if out="$("$bin" "$flag" 2>&1)" && [[ -n "$out" ]]; then
      echo "$out" | head -1
      return 0
    fi
  done
  return 1
}

# --- bump ------------------------------------------------------------------

CURRENT="$(get_field version)"
if [[ -z "$CURRENT" ]]; then
  echo "error: no \`version = \"...\";\` line found in ${PKG}.nix" >&2
  exit 1
fi
if [[ "$CURRENT" == "$VERSION" ]]; then
  echo "${PKG}.nix is already at ${VERSION}, nothing to do."
  SUCCESS=1
  exit 0
fi

echo "Bumping ${PKG}: ${CURRENT} -> ${VERSION}"
set_field version "$VERSION"

# Guard: the edit must actually have landed.
if [[ "$(get_field version)" != "$VERSION" ]]; then
  echo "error: failed to set version in ${NIX_FILE}" >&2
  exit 1
fi

echo "Resolving hash(es)..."
for f in "${HASH_FIELDS[@]}"; do
  fix_hash_field "$f" || true
done

echo "Verifying build..."
run_build
if [[ -z "$BUILD_OUT" ]]; then
  cat "$ERRFILE" >&2
  echo "error: build failed" >&2
  exit 1
fi

# Pick the output that has a bin/ dir (multi-output packages print several).
OUT_PATH=""
while IFS= read -r p; do
  [[ -d "$p/bin" ]] && { OUT_PATH="$p"; break; }
done <<<"$BUILD_OUT"
[[ -n "$OUT_PATH" ]] || OUT_PATH="$(echo "$BUILD_OUT" | head -1)"

echo "Built: ${OUT_PATH}"

BIN="$(find "$OUT_PATH/bin" -maxdepth 1 \( -type f -o -type l \) 2>/dev/null | sort | head -1)"
REPORTED=""
if [[ -n "$BIN" ]]; then
  REPORTED="$(reported_version "$BIN" || true)"
  echo "Reported version: ${REPORTED:-"(binary has no version flag)"}"
fi

# Guard: what we built must actually be the version we asked for.
if [[ "$OUT_PATH" != *"$VERSION"* && "$REPORTED" != *"$VERSION"* ]]; then
  echo "error: built output doesn't look like ${VERSION}" >&2
  echo "       store path: ${OUT_PATH}" >&2
  echo "       reported:   ${REPORTED:-n/a}" >&2
  exit 1
fi

SUCCESS=1
echo
echo "✓ ${PKG} bumped to ${VERSION}."
echo "Next steps:"
echo "  git diff ${NIX_FILE#"${REPO_ROOT}/"}"
echo "  git add ${NIX_FILE#"${REPO_ROOT}/"}"
echo "  git commit -m \"chore: upgrade ${PKG} to ${VERSION}\""
