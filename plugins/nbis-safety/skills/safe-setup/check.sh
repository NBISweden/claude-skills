#!/usr/bin/env bash
# Read-only check of a project before /nbis-safety:safe-setup writes anything.
# Prints file names and settings keys only, never file contents. The one exception is the
# sandbox and permission-mode keys listed under "Existing sandbox settings": paths, hosts and
# command patterns the user must review.
# Usage: check.sh [project-dir]   (default: current directory)
set -u
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${1:-.}" || exit 1
project=$(pwd -P)
# shellcheck source=lib-project.sh
. "$here/lib-project.sh"

check_claude_version

check_endpoint

say "== Sandbox dependencies"
case "$(uname -s)" in
  Linux)
    for t in bwrap socat; do
      if command -v "$t" >/dev/null; then say "ok: $t"; else say "MISSING: $t (sudo apt-get install bubblewrap socat)"; fi
    done
    if command -v bwrap >/dev/null; then
      ctx=$(bwrap --ro-bind / / --dev /dev --proc /proc cat /proc/self/attr/current 2>/dev/null | tr -d '\0')
      case "$ctx" in
        *unpriv_bwrap*) say "BLOCKED: AppArmor confines bwrap as unpriv_bwrap; sandboxed commands will fail (Ubuntu's bwrap-userns-restrict profile)" ;;
        "") say "could not test bwrap (already inside a sandbox, or blocked)" ;;
        *) say "ok: bwrap runs as: $ctx" ;;
      esac
    fi ;;
  Darwin) say "ok: macOS uses Seatbelt" ;;
  *) say "UNSUPPORTED: $(uname -s) has no Claude Code sandbox" ;;
esac

say "== Toolchain under home (needs allowRead when home is denied)"
dirs=()   # paths relative to $HOME
skipped=()
keep() {   # $1: absolute directory to re-open for reading
  case "$1" in "$HOME"/*) ;; *) return ;; esac
  case "$1/" in "$project"/*) return ;; esac   # inside the project: readable already
  case "$project/" in "$1"/*) skipped+=("${1#"$HOME"/}"); return ;; esac
  dirs+=("${1#"$HOME"/}")
}
root_of() {   # $1: executable path; prints the install root (the part before the last /bin/)
  # shortcut: assumes the <root>/bin/<tool> layout of conda, venv, pyenv, nvm; fine for those
  local r=${1%/bin/*}
  [ "$r" = "$1" ] && r=$(dirname "$1")
  case "$r" in
    "$HOME") echo "$HOME/bin" ;;
    "$HOME/.local") echo "$HOME/.local/bin"; echo "$HOME/.local/lib" ;;   # not ~/.local/share
    *) echo "$r" ;;
  esac
}
for t in python python3 R Rscript conda mamba micromamba node nextflow snakemake java; do
  p=$(command -v "$t" 2>/dev/null) || continue
  while read -r r; do keep "$r"; done < <(root_of "$(readlink -f "$p")")
done
for p in "${CONDA_PREFIX:-}" "$(conda info --base 2>/dev/null)"; do
  [ -n "$p" ] && keep "$p"
done
[ -d ~/R ] && keep "$HOME/R"
# PATH entries under home, exactly (hooks such as rtk run from there inside the sandbox)
IFS=: read -ra path_dirs <<<"$PATH"
for p in "${path_dirs[@]}"; do
  [ -d "$p" ] && keep "$p"
done
if [ "${#dirs[@]}" -gt 0 ]; then printf '%s\n' "${dirs[@]/#/\~/}" | sort -u; else say "(none)"; fi
[ "${#skipped[@]}" -gt 0 ] && printf 'SKIPPED (holds the project, never allow it): %s\n' "${skipped[@]/#/\~/}" | sort -u

say "== Existing sandbox settings (merged with what safe-setup writes; review each)"
if command -v jq >/dev/null; then
  for f in ~/.claude/settings.json .claude/settings.json .claude/settings.local.json; do
    [ -f "$f" ] || continue
    jq -r --arg f "$f" '
      (.sandbox // {}) as $s |
      [ ($s.enabled == false | select(.) | "sandbox.enabled is false"),
        ($s.failIfUnavailable == false | select(.) | "sandbox.failIfUnavailable is false"),
        ($s.allowUnsandboxedCommands == true | select(.) | "sandbox.allowUnsandboxedCommands is true"),
        ($s.autoAllowBashIfSandboxed == true | select(.) | "sandbox.autoAllowBashIfSandboxed is true"),
        ($s.filesystem.disabled == true | select(.) | "sandbox.filesystem.disabled is true"),
        ($s.enableWeakerNestedSandbox == true | select(.) | "sandbox.enableWeakerNestedSandbox is true"),
        ($s.enableWeakerNetworkIsolation == true | select(.) | "sandbox.enableWeakerNetworkIsolation is true"),
        ($s.excludedCommands[]? | "sandbox.excludedCommands: \(.)"),
        ($s.filesystem.allowRead[]? | "sandbox.filesystem.allowRead: \(.)"),
        ($s.filesystem.allowWrite[]? | "sandbox.filesystem.allowWrite: \(.)"),
        ($s.network.allowedDomains[]? | "sandbox.network.allowedDomains: \(.)"),
        ($s.network.strictAllowlist == true | select(.) | "sandbox.network.strictAllowlist is true"),
        (.permissions.defaultMode // empty | select(. == "bypassPermissions" or . == "auto") | "permissions.defaultMode is \(.)")
      ] | .[] | "\($f): \(.)"' "$f" 2>/dev/null || say "$f: not valid JSON"
  done
  say "(done)"
else say "jq not installed, skipped: check these files by hand"
fi

say "== Project: $project"
case "$project" in "$HOME") say "WARNING: this is your home directory, run from a project folder" ;; esac
scan_project

say "== MCP servers (names only)"
scan_mcp

say "== gitleaks"
scan_gitleaks
