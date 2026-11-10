#!/usr/bin/env bash
# What the sandbox blocks, seen from inside a Claude Code session. Prints outcomes only (ok, fail
# or a count), never file names or content. Not a CI test: it uses the network and touches home, so
# it lives below tests/, out of CI's tests/*.sh loop (tests/test-check.sh runs it with fakes).
# Copy it into the project and run it from the project root:
#   bash probe.sh [data-file]      ask Claude to run it in a session; run it once in a terminal as the control
#   bash probe.sh --check-marker   in a terminal afterwards: did the home write reach the real home?
#                                  (removes the marker if it is there)
set -u
marker=~/.nbis-probe-marker
if [ "${1:-}" = --check-marker ]; then
  if [ -e "$marker" ]; then rm -f "$marker"; echo "home marker: present (removed)"; else echo "home marker: absent"; fi
  exit 0
fi
data=${1:-data/sample1.fastq}
r() { if "$@" >/dev/null 2>&1; then echo ok; else echo fail; fi; }
count() { local n=0 f; for f in "$1"/* "$1"/.[!.]*; do [ -e "$f" ] && n=$((n + 1)); done; echo "$n entries"; }
echo "ls ~/.ssh: $(r ls ~/.ssh)"
echo "ls ~: $(count ~)"
echo "read ~/.claude/settings.json: $(r cat ~/.claude/settings.json)"
echo "read canary content: $(r grep -qx 'nbis-safety canary: this file holds nothing secret' .nbis-safety/blocked/canary)"
echo "ls canary folder: $(count .nbis-safety/blocked)"
echo "read data file: $(r cat "$data")"
echo "write in project: $(r sh -c 'echo probe > .nbis-probe-tmp && rm .nbis-probe-tmp')"
echo "write in home: $(r touch "$marker")"
echo "listed host: $(r curl -q -s -o /dev/null --max-time 8 https://pypi.org)"
echo "unlisted host: $(r curl -q -s -o /dev/null --max-time 8 https://example.com)"
