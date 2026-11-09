# Shared by check.sh and ../container-setup/check-container.sh (sourced, read-only).
# Needs: $project (absolute project directory) for scan_project and scan_mcp.

say() { printf '%s\n' "$*"; }
ver_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

check_claude_version() {
say "== Claude Code"
v=$(claude --version 2>/dev/null | awk '{print $1}')
if [ -z "$v" ]; then say "NOT FOUND: claude"
elif ver_ge "$v" 2.1.290; then say "ok: $v"
else say "TOO OLD: $v (2.1.290 or later needed: older versions have read-deny bypasses, e.g. wildcard denies on macOS before 2.1.236)"
fi
}

check_endpoint() {
say "== Model endpoint"
[ -n "${ANTHROPIC_BASE_URL:-}" ] && say "WARNING: ANTHROPIC_BASE_URL is set in the environment"
for f in ~/.claude/settings.json .claude/settings.json .claude/settings.local.json; do
  grep -q ANTHROPIC_BASE_URL "$f" 2>/dev/null && say "WARNING: ANTHROPIC_BASE_URL is set in $f"
done
say "(done)"
}

scan_project() {
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
}

scan_mcp() {
if command -v jq >/dev/null; then
  [ -f .mcp.json ] && jq -r '(.mcpServers // {}) | keys[] | "project: \(.)"' .mcp.json 2>/dev/null
  [ -f ~/.claude.json ] && jq -r --arg p "$project" '((.mcpServers // {}) | keys[] | "user: \(.)"),
    ((.projects[$p].mcpServers // {}) | keys[] | "local: \(.)")' ~/.claude.json 2>/dev/null
  say "(done)"
else say "jq not installed, skipped"
fi
}

scan_gitleaks() {
if command -v gitleaks >/dev/null; then
  timeout 120 gitleaks dir . --redact --no-banner >/dev/null 2>&1
  case $? in 0) say "no leaks found" ;; 1) say "LEAKS FOUND: run 'gitleaks dir . --redact' yourself to see where" ;; *) say "did not finish" ;; esac
else say "not installed, skipped"
fi
}
