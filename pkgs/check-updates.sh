#!/usr/bin/env bash
# pkgs/check-updates.sh — compare pinned versions in pkgs/*.nix against latest upstream
# Usage: pkgs/check-updates.sh [pkg ...]
#   no args -> check every package in the list below
#   pkg ...  -> check only those (e.g. pkgs/check-updates.sh go gopls)
#
# Read-only: prints a table of current vs latest, then a summary of what is
# outdated, with the exact bump.sh command for each. A failed lookup shows the
# real error instead of a bare "lookup failed". Lookups run in parallel.
#
# Needs: git, curl, python3. `gh` (authenticated) is used when available; if it
# is missing or not logged in, GitHub-hosted tools fall back to `git ls-remote`
# on tags, which needs no token and has no API rate limit.
#
# Works with macOS's stock bash 3.2 (no associative arrays, mapfile, wait -n).
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
export GIT_TERMINAL_PROMPT=0

for t in git curl python3; do
  command -v "$t" >/dev/null || { echo "error: $t is required" >&2; exit 1; }
done

HAVE_GH=0
if command -v gh >/dev/null && gh auth status >/dev/null 2>&1; then
  HAVE_GH=1
else
  echo "warn: gh missing or not authenticated; using git tags instead of GitHub releases" >&2
fi

# Each entry: pkg_file:lookup command (a function below, plus its arguments)
PKGS=(
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
  "lua-language-server:gh_latest LuaLS/lua-language-server"
  "terraform-ls:gh_latest hashicorp/terraform-ls"
  "helm-ls:gh_latest mrjosh/helm-ls"
  "ols:ols_latest"
  "omnisharp:gh_latest OmniSharp/omnisharp-roslyn"
  "minimaldoc:gh_latest studiowebux/minimaldoc"
  "timeago:gh_latest studiowebux/timeago"
  "tea:tea_latest"
  "helix:gh_latest helix-editor/helix"
  "odin:odin_latest"
)

# --- helpers ---------------------------------------------------------------

SEMVER_RE='^v?[0-9]+(\.[0-9]+)+$'

# Version pinned in a .nix file: first top-level `version = "...";` line.
current_version() {
  grep -E '^[[:space:]]*version[[:space:]]*=' "$1" | head -1 | sed -E 's/.*"([^"]+)".*/\1/'
}

# stdin filter: drop a leading "v"
strip_v() { sed -E 's/^v//'; }

# curl that follows redirects (dl.k8s.io redirects), retries, and fails on HTTP errors
fetch() {
  curl -fsSL --retry 2 --connect-timeout 10 --max-time 30 -A "pkgs-check-updates" "$@"
}

# Newest tag of a git repo matching a regex (default: plain X.Y[.Z...] with an
# optional leading v, so -rc/-beta tags are ignored). No API token needed.
git_latest_tag() {
  local url="$1" re="${2:-$SEMVER_RE}" tags
  tags="$(git ls-remote --tags --refs "$url")" || return 1
  printf '%s\n' "$tags" | sed -E 's#.*refs/tags/##' | grep -E "$re" | sort -V | tail -1
}

# Latest GitHub release tag; falls back to the newest tag for repos that only
# push tags (no Releases), or when gh is unavailable / rate limited.
gh_latest() {
  local repo="$1" tag=""
  if [[ "$HAVE_GH" == 1 ]]; then
    tag="$(gh api "repos/$repo/releases/latest" --jq '.tag_name // empty')" || tag=""
    if [[ -n "$tag" ]]; then
      printf '%s\n' "$tag" | strip_v
      return 0
    fi
    # No Release (tag-only repo): list tags through the API so private repos work.
    tag="$(gh api "repos/$repo/tags?per_page=100" --jq '.[].name' \
      | grep -E "$SEMVER_RE" | sort -V | tail -1)" || tag=""
    if [[ -n "$tag" ]]; then
      printf '%s\n' "$tag" | strip_v
      return 0
    fi
  fi
  git_latest_tag "https://github.com/$repo" | strip_v
}

# gopls and kustomize live in monorepos and are tagged "gopls/vX.Y.Z" and
# "kustomize/vX.Y.Z"; golang/tools has no GitHub Releases at all, and the
# kustomize releases list is buried under api/ and kyaml/ releases.
gopls_latest() {
  git_latest_tag https://github.com/golang/tools '^gopls/v[0-9]+\.[0-9]+\.[0-9]+$' \
    | sed -E 's#^gopls/v##'
}

kustomize_latest() {
  git_latest_tag https://github.com/kubernetes-sigs/kustomize '^kustomize/v[0-9]+\.[0-9]+\.[0-9]+$' \
    | sed -E 's#^kustomize/v##'
}

kubectl_latest() {
  fetch https://dl.k8s.io/release/stable.txt | strip_v
}

go_latest() {
  fetch "https://go.dev/dl/?mode=json" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)[0]['version'])" \
    | sed -E 's/^go//'
}

claude_latest() {
  # No public "latest" index for the standalone binary; the npm package tracks
  # the same release train, so use its registry metadata instead.
  fetch "https://registry.npmjs.org/@anthropic-ai/claude-code/latest" \
    | python3 -c "import json,sys; print(json.load(sys.stdin)['version'])"
}

ols_latest() {
  # Dated dev tags (and a rolling "nightly" release that must be skipped).
  local tag=""
  if [[ "$HAVE_GH" == 1 ]]; then
    tag="$(gh api repos/DanielGavin/ols/releases \
      --jq '[.[] | select(.tag_name != "nightly")][0].tag_name // empty')" || tag=""
    if [[ -n "$tag" ]]; then
      printf '%s\n' "$tag"
      return 0
    fi
  fi
  git_latest_tag https://github.com/DanielGavin/ols '^dev-[0-9]'
}

tea_latest() {
  git_latest_tag https://gitea.com/gitea/tea | strip_v
}

odin_latest() {
  # Pinned to a dated dev tag (e.g. dev-2026-03). These don't show up in the
  # GitHub REST /tags listing, so go straight to the git ref advertisement.
  git_latest_tag https://github.com/odin-lang/Odin '^dev-[0-9]{4}-[0-9]{2}$'
}

# --- select ----------------------------------------------------------------

SELECTED=()
for entry in "${PKGS[@]}"; do
  pkg="${entry%%:*}"
  if [[ $# -gt 0 ]]; then
    match=0
    for want in "$@"; do
      [[ "$want" == "$pkg" ]] && match=1
    done
    [[ "$match" == 1 ]] || continue
  fi
  SELECTED+=("$entry")
done
if [[ ${#SELECTED[@]} -eq 0 ]]; then
  echo "error: no matching packages for: $*" >&2
  exit 1
fi

# --- look everything up (8 at a time) -------------------------------------

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

n=0
for entry in "${SELECTED[@]}"; do
  pkg="${entry%%:*}"
  fn="${entry#*:}"
  ( $fn >"$TMP/$pkg.out" 2>"$TMP/$pkg.err" ) &
  n=$((n + 1))
  if (( n % 8 == 0 )); then wait; fi
done
wait

# --- report ----------------------------------------------------------------

printf "%-22s %-16s %-16s %s\n" "PACKAGE" "CURRENT" "LATEST" "STATUS"
printf "%-22s %-16s %-16s %s\n" "-------" "-------" "------" "------"

outdated=()
bumps=()
unknown=()

for entry in "${SELECTED[@]}"; do
  pkg="${entry%%:*}"
  file="${pkg}.nix"
  if [[ ! -f "$file" ]]; then
    echo "warn: $file not found" >&2
    continue
  fi

  cur="$(current_version "$file")"
  latest="$(head -1 "$TMP/$pkg.out" | tr -d '[:space:]')"
  [[ "$latest" == "null" ]] && latest=""

  if [[ -z "$cur" ]]; then
    status="? (no version in file)"
    unknown+=("$pkg: no \`version = \"...\";\` line in ${file}")
  elif [[ -z "$latest" ]]; then
    status="? (lookup failed)"
    reason="$(grep -v '^[[:space:]]*$' "$TMP/$pkg.err" | head -1)"
    unknown+=("$pkg: ${reason:-no output from lookup}")
  elif [[ "${cur#v}" == "${latest#v}" ]]; then
    status="up to date"
  else
    status="UPDATE -> ${latest}"
    outdated+=("$pkg: ${cur} -> ${latest}")
    bumps+=("pkgs/bump.sh ${pkg} ${latest}")
  fi

  printf "%-22s %-16s %-16s %s\n" "$pkg" "${cur:-?}" "${latest:-?}" "$status"
done

echo
echo "=== Summary ==="
if [[ ${#outdated[@]} -eq 0 ]]; then
  echo "Everything checked is up to date."
else
  echo "${#outdated[@]} package(s) need updating:"
  for line in "${outdated[@]}"; do
    echo "  - $line"
  done
  echo
  echo "To bump:"
  for line in "${bumps[@]}"; do
    echo "  $line"
  done
fi
if [[ ${#unknown[@]} -gt 0 ]]; then
  echo
  echo "${#unknown[@]} package(s) could not be checked:"
  for line in "${unknown[@]}"; do
    echo "  - $line"
  done
fi
