#!/usr/bin/env bash
# Repository rules from CONTRIBUTING.md that `claude plugin validate` does not check.
# Usage: scripts/check-structure.sh [base-ref]   (base-ref enables the version-bump check)
set -u
cd "$(dirname "$0")/.." || exit 1
base=${1:-}
fail=0
err() { printf 'ERROR: %s\n' "$*"; fail=1; }

for src in $(jq -r '.plugins[].source' .claude-plugin/marketplace.json); do
  dir=${src#./}
  name=$(jq -r '.name' "$dir/.claude-plugin/plugin.json" 2>/dev/null) || { err "$dir: no readable plugin.json"; continue; }
  listed=$(jq -r --arg s "$src" '.plugins[] | select(.source == $s) | .name' .claude-plugin/marketplace.json)
  [ "$name" = "$listed" ] || err "$dir: plugin.json name '$name' differs from marketplace name '$listed'"
  grep -Eq "^/$dir/[[:space:]]+@" CODEOWNERS || err "$dir: no owner in CODEOWNERS; add the line '/$dir/ @your-github-name'"
  ls "$dir"/evals/*/prompt.md >/dev/null 2>&1 || err "$dir: no eval case (evals/<case>/prompt.md)"
  for s in "$dir"/skills/*/SKILL.md; do
    [ -e "$s" ] || continue
    skill=$(basename "$(dirname "$s")")
    grep -q "^name: $skill\$" "$s" || err "$s: 'name:' must be '$skill'"
    grep -q '^description: ' "$s" || err "$s: missing 'description:'"
    grep -qF "\`/$name:$skill\`" README.md || err "$s: README has no row for /$name:$skill"
  done
  if [ -n "$base" ] && ! git diff --quiet "$base"...HEAD -- "$dir"; then
    old=$(git show "$base:$dir/.claude-plugin/plugin.json" 2>/dev/null | jq -r '.version') || old=""
    new=$(jq -r '.version' "$dir/.claude-plugin/plugin.json")
    [ -n "$old" ] && [ "$old" = "$new" ] && err "$dir changed but its version is still $new"
  fi
done

for d in plugins/*/; do
  d=${d%/}
  [[ ${d#plugins/} =~ ^[a-z0-9][a-z0-9-]*$ ]] || err "$d: plugin directory names must be lowercase letters, digits and hyphens"
  jq -e --arg s "./$d" 'any(.plugins[]; .source == $s)' .claude-plugin/marketplace.json >/dev/null \
    || err "$d is not listed in .claude-plugin/marketplace.json"
done

[ "$fail" = 0 ] && echo "structure ok"
exit "$fail"
