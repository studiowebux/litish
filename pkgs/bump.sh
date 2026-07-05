#!/usr/bin/env bash
# pkgs/bump.sh — bump a pinned tool in pkgs/<pkg>.nix to a given version
# Usage: pkgs/bump.sh <pkg> <version>
#   e.g. pkgs/bump.sh terraform 1.15.7
#        pkgs/bump.sh gopls 0.22.0
#
# Works for any pkgs/*.nix that pins a single `version = "...";` and one or
# more `hash = "...";` / `vendorHash = "...";` fields (fetchurl, fetchzip,
# fetchFromGitHub, buildGoModule). Rather than know each fetcher's hashing
# scheme, it fakes the hash, lets the build fail with a mismatch, and reads
# the correct value back out of Nix's error message — then verifies the
# real build actually produces a working binary before leaving the change
# in place. On any failure the file is restored untouched.
#
# Pair with pkgs/check-updates.sh to see what needs bumping.
set -uo pipefail

if sed --version 2>/dev/null | grep -q GNU; then
  sed_i() { sed -i "$@"; }
else
  sed_i() { sed -i '' "$@"; }
fi

PKG="${1:-}"
VERSION="${2:-}"
if [[ -z "$PKG" || -z "$VERSION" ]]; then
  echo "usage: $0 <pkg> <version>   (e.g. $0 terraform 1.15.7)" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_FILE="${SCRIPT_DIR}/${PKG}.nix"
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"
FAKE_HASH="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

[[ -f "$NIX_FILE" ]] || { echo "error: $NIX_FILE not found" >&2; exit 1; }

BACKUP="$(mktemp)"
cp "$NIX_FILE" "$BACKUP"
cleanup_on_fail() {
  echo "Restoring ${NIX_FILE} (build failed)." >&2
  cp "$BACKUP" "$NIX_FILE"
  rm -f "$BACKUP"
}

CURRENT="$(grep -E '^\s*version\s*=' "$NIX_FILE" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')"
if [[ "$CURRENT" == "$VERSION" ]]; then
  echo "${PKG}.nix is already at ${VERSION}, nothing to do."
  rm -f "$BACKUP"
  exit 0
fi

echo "Bumping ${PKG}: ${CURRENT} -> ${VERSION}"
sed_i -E "0,/version[[:space:]]*=.*/s//version = \"${VERSION}\";/" "$NIX_FILE"

build_expr() {
  echo "
    let
      flake = builtins.getFlake (toString ${REPO_ROOT});
      pkgs  = flake.inputs.nixpkgs.legacyPackages.aarch64-darwin;
    in pkgs.callPackage ${NIX_FILE} {}
  "
}

# Fakes $field's hash, rebuilds, and rewrites it with the value Nix reports.
# Returns 0 if a mismatch was found and fixed, 1 if the field wasn't the
# problem (already correct, or doesn't exist in this file).
fix_hash_field() {
  local field="$1"
  grep -qE "^[[:space:]]*${field}[[:space:]]*=" "$NIX_FILE" || return 1

  local before
  before="$(grep -E "^[[:space:]]*${field}[[:space:]]*=" "$NIX_FILE" | head -1)"
  sed_i -E "s|^([[:space:]]*${field}[[:space:]]*=[[:space:]]*)\"[^\"]*\"|\1\"${FAKE_HASH}\"|" "$NIX_FILE"

  local out
  out="$(nix build --no-link --print-out-paths --impure --expr "$(build_expr)" 2>&1)"

  local got
  got="$(echo "$out" | grep -A1 "specified:" | grep "got:" | head -1 | sed -E 's/.*got:[[:space:]]*//')"

  if [[ -z "$got" ]]; then
    # No mismatch reported for this field — put the original back.
    sed_i -E "s|^[[:space:]]*${field}[[:space:]]*=.*|${before}|" "$NIX_FILE"
    return 1
  fi

  echo "  ${field}: ${got}"
  sed_i -E "s|^([[:space:]]*${field}[[:space:]]*=[[:space:]]*)\"${FAKE_HASH//\+/\\+}\"|\1\"${got}\"|" "$NIX_FILE"
  return 0
}

echo "Resolving hash(es)..."
fix_hash_field "hash"
fix_hash_field "vendorHash"

echo "Verifying build..."
OUT="$(nix build --no-link --print-out-paths --impure --expr "$(build_expr)" 2>&1)"
if [[ $? -ne 0 ]]; then
  echo "$OUT" >&2
  cleanup_on_fail
  exit 1
fi
OUT_PATH="$(echo "$OUT" | tail -1)"

if [[ ! -d "$OUT_PATH" ]]; then
  echo "error: build produced no output path" >&2
  cleanup_on_fail
  exit 1
fi

BIN="$(find "$OUT_PATH/bin" -maxdepth 1 -type f 2>/dev/null | head -1)"
echo "Built: ${OUT_PATH}"
if [[ -n "$BIN" ]]; then
  echo -n "Reported version: "
  "$BIN" --version 2>&1 | head -1 || "$BIN" version 2>&1 | head -1 || echo "(binary doesn't support --version/version)"
fi

rm -f "$BACKUP"
echo
echo "✓ ${PKG} bumped to ${VERSION}."
echo "Next steps:"
echo "  git add ${NIX_FILE#"${REPO_ROOT}/"}"
echo "  git commit -m \"chore: upgrade ${PKG} to ${VERSION}\""
