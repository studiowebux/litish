#!/usr/bin/env bash
# pkgs/check-updates.sh — compare pinned versions in pkgs/*.nix against latest upstream
# Usage: pkgs/check-updates.sh
#
# Read-only: prints a table of current vs latest, then a summary of what's
# outdated. Does not touch any files. Requires `gh` (authenticated) and `curl`.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

current_version() {
  grep -E '^\s*version\s*=' "$1" | head -1 | sed -E 's/.*"([^"]+)".*/\1/'
}

# Each entry: pkg_file:lookup_fn
declare -a PKGS=(
  "deno:gh_latest denoland/deno"
  "gh:gh_latest cli/cli"
  "gopls:gopls_latest"
  "go:go_latest"
  "cerveau:gh_latest studiowebux/cerveau.dev"
  "claude:claude_latest"
  "kubectl:kubectl_latest"
  "cilium:gh_latest cilium/cilium-cli"
  "hubble:gh_latest cilium/hubble"
  "kubeseal:gh_latest bitnami-labs/sealed-secrets"
  "kustomize:kustomize_latest"
  "flux:gh_latest fluxcd/flux2"
  "helm:gh_latest helm/helm"
  "terraform:gh_latest hashicorp/terraform"
  "lua-language-server:lua_ls_latest"
  "terraform-ls:gh_latest hashicorp/terraform-ls"
  "helm-ls:gh_latest mrjosh/helm-ls"
  "ols:ols_latest"
  "omnisharp:gh_latest OmniSharp/omnisharp-roslyn"
  "sshtui:gh_latest_notag studiowebux/sshtui"
  "minimaldoc:gh_latest studiowebux/minimaldoc"
  "restcli:gh_latest_notag studiowebux/restcli"
  "proxytui:gh_latest_notag studiowebux/proxytui"
  "timeago:gh_latest_notag studiowebux/timeago"
  "lspmcp:gh_latest studiowebux/lspmcp"
  "bujotui:gh_latest studiowebux/bujotui"
  "bujotui-mcp:gh_latest studiowebux/bujotui"
  "spacetimedb:gh_latest clockworklabs/SpacetimeDB"
  "tea:tea_latest"
  "helix:helix_latest"
  "odin:odin_latest"
)

strip_v() { echo "$1" | sed -E 's/^v//'; }

# Plain "vX.Y.Z" -> "X.Y.Z" tag_name lookups
gh_latest() {
  local tag
  tag="$(gh api "repos/$1/releases/latest" --jq '.tag_name' 2>/dev/null)"
  strip_v "$tag"
}

# Same, but pname has no leading "v" in the tag either (still safe to strip_v)
gh_latest_notag() { gh_latest "$1"; }

gopls_latest() {
  gh api repos/golang/tools/releases --jq '[.[] | select(.tag_name | startswith("gopls/v"))][0].tag_name' 2>/dev/null \
    | sed -E 's#gopls/v##'
}

kustomize_latest() {
  gh api repos/kubernetes-sigs/kustomize/releases --jq '[.[] | select(.tag_name | startswith("kustomize/v"))][0].tag_name' 2>/dev/null \
    | sed -E 's#kustomize/v##'
}

kubectl_latest() {
  curl -sf https://dl.k8s.io/release/stable.txt | strip_v_stdin
}
strip_v_stdin() { sed -E 's/^v//'; }

go_latest() {
  curl -sf "https://go.dev/dl/?mode=json" | python3 -c "import json,sys; print(json.load(sys.stdin)[0]['version'].removeprefix('go'))" 2>/dev/null
}

claude_latest() {
  # No public "latest" index for the standalone binary; the npm package tracks
  # the same release train, so use its registry metadata instead.
  curl -sf "https://registry.npmjs.org/@anthropic-ai/claude-code/latest" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['version'])" 2>/dev/null
}

lua_ls_latest() {
  gh api repos/LuaLS/lua-language-server/releases/latest --jq '.tag_name' 2>/dev/null
}

ols_latest() {
  gh api repos/DanielGavin/ols/releases --jq '[.[] | select(.tag_name != "nightly")][0].tag_name' 2>/dev/null
}

tea_latest() {
  curl -sf "https://gitea.com/api/v1/repos/gitea/tea/releases?limit=1" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)[0]['tag_name'])" 2>/dev/null \
    | strip_v_stdin
}

helix_latest() {
  gh api repos/helix-editor/helix/releases/latest --jq '.tag_name' 2>/dev/null
}

odin_latest() {
  # Pinned to a dated dev tag (e.g. dev-2026-03). These don't show up in the
  # GitHub REST /tags listing, so go straight to the git ref advertisement.
  git ls-remote --tags --refs https://github.com/odin-lang/Odin 2>/dev/null \
    | sed -E 's#.*refs/tags/##' \
    | grep -E '^dev-[0-9]{4}-[0-9]{2}$' \
    | sort -V \
    | tail -1
}

printf "%-22s %-16s %-16s %s\n" "PACKAGE" "CURRENT" "LATEST" "STATUS"
printf "%-22s %-16s %-16s %s\n" "-------" "-------" "------" "------"

outdated=()
unknown=()

for entry in "${PKGS[@]}"; do
  pkg="${entry%%:*}"
  fn="${entry#*:}"
  file="${pkg}.nix"
  [[ -f "$file" ]] || { echo "warn: $file not found" >&2; continue; }

  cur="$(current_version "$file")"
  latest="$(eval "$fn" 2>/dev/null)"

  if [[ -z "$latest" ]]; then
    status="? (lookup failed)"
    unknown+=("$pkg")
  elif [[ "$cur" == "$latest" ]]; then
    status="up to date"
  else
    status="UPDATE -> ${latest}"
    outdated+=("$pkg: ${cur} -> ${latest}")
  fi

  printf "%-22s %-16s %-16s %s\n" "$pkg" "$cur" "${latest:-?}" "$status"
done

echo
echo "=== Summary ==="
if [[ ${#outdated[@]} -eq 0 ]]; then
  echo "Everything pinned is up to date."
else
  echo "${#outdated[@]} package(s) need updating:"
  for line in "${outdated[@]}"; do
    echo "  - $line"
  done
fi
if [[ ${#unknown[@]} -gt 0 ]]; then
  echo
  echo "${#unknown[@]} package(s) could not be checked (rate limit / no API / network):"
  for pkg in "${unknown[@]}"; do
    echo "  - $pkg"
  done
fi
