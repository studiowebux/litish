#!/usr/bin/env bash
# bump-claude.sh — bump the pinned claude-code version in pkgs/claude.nix
# Usage: pkgs/bump-claude.sh <version>
#   e.g. pkgs/bump-claude.sh 2.1.168
#
# Downloads the darwin-arm64 binary for the given version, computes its SRI
# hash, and rewrites the version + hash fields in pkgs/claude.nix.
set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "usage: $0 <version>   (e.g. $0 2.1.168)" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIX_FILE="${SCRIPT_DIR}/claude.nix"
URL="https://downloads.claude.ai/claude-code-releases/${VERSION}/darwin-arm64/claude"

CURRENT="$(grep -E 'version\s*=' "$NIX_FILE" | head -1 | sed -E 's/.*"([^"]+)".*/\1/')"
if [[ "$CURRENT" == "$VERSION" ]]; then
  echo "claude.nix is already at ${VERSION}, nothing to do."
  exit 0
fi

echo "Bumping claude-code: ${CURRENT} -> ${VERSION}"
echo "Fetching ${URL} ..."

NIX32="$(nix-prefetch-url "$URL" 2>/dev/null | tail -1)"
if [[ -z "$NIX32" ]]; then
  echo "error: failed to download/hash ${URL}" >&2
  exit 1
fi

SRI="$(nix hash convert --hash-algo sha256 --to sri "$NIX32" 2>/dev/null \
  || nix-hash --to-sri --type sha256 "$NIX32")"

echo "New hash: ${SRI}"

# Rewrite version (first match) and the claude hash line.
sed -i '' -E \
  -e "0,/version[[:space:]]*=.*/s//version = \"${VERSION}\";/" \
  -e "s|hash[[:space:]]*=[[:space:]]*\"sha256-[^\"]*\";|hash = \"${SRI}\";|" \
  "$NIX_FILE"

echo "Updated ${NIX_FILE}:"
grep -E 'version|hash' "$NIX_FILE"

# ── Verify the upgrade actually builds and runs ───────────────────────────────
# Build claude.nix against the flake's pinned nixpkgs (not the system channel),
# callPackage'ing the on-disk file so the just-written version/hash are used.
# This re-fetches via the new hash (failing loudly on any mismatch) and proves
# the install phase + binary work before we ever commit.
REPO_ROOT="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)"

echo "Verifying build against the flake's pinned nixpkgs ..."
OUT="$(nix build --no-link --print-out-paths --impure --expr "
  let
    flake = builtins.getFlake (toString ${REPO_ROOT});
    pkgs  = flake.inputs.nixpkgs.legacyPackages.aarch64-darwin;
  in pkgs.callPackage ${NIX_FILE} {}
")"

if [[ -z "$OUT" || ! -x "$OUT/bin/claude" ]]; then
  echo "error: build produced no usable claude binary" >&2
  exit 1
fi

echo "Built: ${OUT}"
echo -n "Reported version: "
REPORTED="$("$OUT/bin/claude" --version 2>&1 | head -1)"
echo "$REPORTED"

if [[ "$REPORTED" != *"$VERSION"* ]]; then
  echo "error: built binary does not report ${VERSION} (got: ${REPORTED})" >&2
  exit 1
fi

echo
echo "✓ ${VERSION} builds and runs."
echo "Next steps:"
echo "  git add ${NIX_FILE#"${REPO_ROOT}/"}"
echo "  git commit -m \"chore: upgrade claude-code to ${VERSION}\""
