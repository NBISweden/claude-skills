#!/usr/bin/env bash
# Read-only check of a project before /nbis-safety:safe-setup writes anything.
# Prints file names and settings keys only, never file contents. The one exception is the
# sandbox and permission-mode keys listed under "Existing sandbox settings": paths, hosts and
# command patterns the user must review.
# Usage: check.sh [project-dir]   (default: current directory)
set -u
cd "${1:-.}" || exit 1
project=$(pwd -P)

say() { printf '%s\n' "$*"; }
ver_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

say "== Claude Code"
v=$(claude --version 2>/dev/null | awk '{print $1}')
if [ -z "$v" ]; then say "NOT FOUND: claude"
elif ver_ge "$v" 2.1.290; then say "ok: $v"
else say "TOO OLD: $v (2.1.290 or later needed: older versions have read-deny bypasses, e.g. wildcard denies on macOS before 2.1.236)"
fi

say "== Model endpoint"
[ -n "${ANTHROPIC_BASE_URL:-}" ] && say "WARNING: ANTHROPIC_BASE_URL is set in the environment"
for f in ~/.claude/settings.json .claude/settings.json .claude/settings.local.json; do
  grep -q ANTHROPIC_BASE_URL "$f" 2>/dev/null && say "WARNING: ANTHROPIC_BASE_URL is set in $f"
done
say "(done)"

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
        (.permissions.defaultMode // empty | select(. == "bypassPermissions") | "permissions.defaultMode is \(.)"),
        (.permissions.deny[]? | select(test("^[A-Za-z]+\\(//\\*\\*")) | "permissions.deny \(.) is not enforced for shell commands on Linux"),
        (select($f | startswith("/")) | .permissions.deny[]? | select(test("^[A-Za-z]+\\(/[^/]")) | "permissions.deny \(.) anchors at ~/.claude here, so it covers no project")
      ] | .[] | "\($f): \(.)"' "$f" 2>/dev/null || say "$f: not valid JSON"
  done
  say "(done)"
else say "jq not installed, skipped: check these files by hand"
fi

say "== Project: $project"
case "$project" in "$HOME") say "WARNING: this is your home directory, run from a project folder" ;; esac
prune=(-name .git -o -name node_modules -o -name .snakemake -o -name work -o -name .venv)
say "-- secret-like files (names only; SKILL.md denies the same patterns)"
find . -maxdepth 5 \( "${prune[@]}" \) -prune -o -type f \( -name '.env' -o -name '.env.*' -o -name '*.pem' -o -name '*.key' \
  -o -name 'id_rsa*' -o -name 'id_ed25519*' -o -name '*.p12' -o -name '.netrc' -o -name 'credentials*' \) -print 2>/dev/null | head -20
say "-- data files by directory (count)"
find . -maxdepth 6 \( "${prune[@]}" \) -prune -o -type f \( -name '*.fastq*' -o -name '*.fq.gz' -o -name '*.fq' -o -name '*.bam' \
  -o -name '*.cram' -o -name '*.sam' -o -name '*.vcf' -o -name '*.vcf.gz' -o -name '*.bcf' -o -name '*.h5ad' -o -name '*.h5' \
  -o -name '*.loom' -o -name '*.mtx' -o -name '*.mtx.gz' -o -name '*.rds' -o -name '*.xlsx' \) -print0 2>/dev/null \
  | xargs -0 -r -n1 dirname | sort | uniq -c | sort -rn | head -10
say "-- existing agent files"
for f in .claude/settings.json .claude/settings.local.json CLAUDE.md .claude/CLAUDE.md CLAUDE.local.md AGENTS.md \
         .github/copilot-instructions.md .vscode/settings.json .mcp.json; do [ -e "$f" ] && say "exists: $f"; done
d=$(dirname "$project")
while [ "$d" != / ]; do
  for f in "$d/CLAUDE.md" "$d/.claude/CLAUDE.md" "$d/CLAUDE.local.md"; do
    # ~/.claude/CLAUDE.md is user memory and does not stop AGENTS.md from loading
    [ "$f" != "$HOME/.claude/CLAUDE.md" ] && [ -e "$f" ] && say "exists above project: $f"
  done
  d=$(dirname "$d")
done

say "== MCP servers (names only)"
if command -v jq >/dev/null; then
  [ -f .mcp.json ] && jq -r '(.mcpServers // {}) | keys[] | "project: \(.)"' .mcp.json 2>/dev/null
  [ -f ~/.claude.json ] && jq -r --arg p "$project" '((.mcpServers // {}) | keys[] | "user: \(.)"),
    ((.projects[$p].mcpServers // {}) | keys[] | "local: \(.)")' ~/.claude.json 2>/dev/null
  say "(done)"
else say "jq not installed, skipped"
fi

say "== gitleaks"
if command -v gitleaks >/dev/null; then
  timeout 120 gitleaks dir . --redact --no-banner >/dev/null 2>&1
  case $? in 0) say "no leaks found" ;; 1) say "LEAKS FOUND: run 'gitleaks dir . --redact' yourself to see where" ;; *) say "did not finish" ;; esac
else say "not installed, skipped"
fi
