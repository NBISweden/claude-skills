#!/usr/bin/env bash
# shellcheck disable=SC2088  # the ~/... strings are literal text that check.sh prints
# check.sh must list secret-like and data files by name, never print their contents,
# re-open only toolchain roots, and report settings that loosen the sandbox.
set -u
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

home=$tmp/home
proj=$home/work/proj
venv=$home/research/code/.venv
mkdir -p "$proj/data" "$proj/src" "$proj/services/api" "$proj/.claude" "$venv/bin" "$home/.local/bin"
echo 'API_KEY=canary-secret-value' > "$proj/.env"
echo 'TOKEN=canary-nested-value' > "$proj/services/api/.env"
printf '@r1\nCANARYREAD\n+\nIIIIIIIIII\n' > "$proj/data/s1.fastq"
echo 'print(1)' > "$proj/src/a.py"
mkdir -p "$home/.claude"
echo '{"permissions":{"deny":["Read(/**/.env)","Read(//**/*.pem)","Read(**/.env)","Read(~/.ssh/**)"]}}' > "$home/.claude/settings.json"
echo '{"sandbox":{"enabled":false,"autoAllowBashIfSandboxed":true,"excludedCommands":["python3 *"]}}' > "$proj/.claude/settings.local.json"
printf '#!/bin/sh\n' > "$venv/bin/python3"
printf '#!/bin/sh\n' > "$home/.local/bin/snakemake"
chmod +x "$venv/bin/python3" "$home/.local/bin/snakemake"

out=$(HOME=$home PATH="$venv/bin:$home/.local/bin:$PATH" CONDA_PREFIX=$home/work \
  bash "$here/../skills/safe-setup/check.sh" "$proj" 2>&1)
fail=0
expect() { grep -qF -- "$1" <<<"$out" || { echo "FAIL: output lacks '$1'"; fail=1; }; }
refuse() { grep -qF -- "$1" <<<"$out" && { echo "FAIL: output contains '$1'"; fail=1; }; }
refuse_line() { grep -qxF -- "$1" <<<"$out" && { echo "FAIL: output has the line '$1'"; fail=1; }; }

expect './.env'
expect './services/api/.env'
expect './data'
expect '== Sandbox dependencies'
refuse 'canary-secret-value'
refuse 'canary-nested-value'
refuse 'CANARYREAD'
# toolchain: the venv root, not the first directory under home
expect '~/research/code/.venv'
refuse_line '~/research'
refuse_line '~/.local'
expect '~/.local/bin'
# a CONDA_PREFIX that holds the project is never re-opened
expect 'SKIPPED (holds the project, never allow it): ~/work'
refuse_line '~/work'
# local settings that loosen the sandbox are reported
expect 'settings.local.json: sandbox.enabled is false'
expect 'settings.local.json: sandbox.excludedCommands: python3 *'
expect 'settings.local.json: sandbox.autoAllowBashIfSandboxed is true'
# the fixture's user settings lack classifyAllShell
expect 'NOTE: autoMode.classifyAllShell is not set'

# user-level deny rules that cover nothing are reported, working ones are not
expect 'permissions.deny Read(/**/.env) anchors at ~/.claude here'
expect 'permissions.deny Read(//**/*.pem) is not enforced for shell commands on Linux'
refuse 'Read(**/.env) anchors'
refuse 'Read(~/.ssh/**) anchors'

# --verify: one line per protection. No test touches the network: curl is a stub that CURL_MODE steers.
check=$here/../skills/safe-setup/check.sh
fakebin=$tmp/fakebin
nocurl=$tmp/nocurl
mkdir -p "$fakebin" "$nocurl" "$home/.ssh"
cat > "$fakebin/curl" <<'EOF'
#!/bin/sh
case "$CURL_MODE" in open) exit 0 ;; offline) exit 6 ;; esac
case "$*" in *pypi.org*) exit 0 ;; esac
exit 7
EOF
chmod +x "$fakebin/curl"
ln -s "$(command -v jq)" "$nocurl/jq"
echo 'not a real key' > "$home/.ssh/id_canary"
verify() { HOME=$home PATH="$fakebin:$PATH" bash "$check" --verify "$proj" 2>&1; }
support='{"sandbox":{"enabled":true,"failIfUnavailable":true,"autoAllowBashIfSandboxed":false,"allowUnsandboxedCommands":false,
  "filesystem":{"denyRead":["~/","./data","./.nbis-safety/blocked"],"allowRead":["."],"denyWrite":["./data"]},
  "network":{"allowedDomains":["pypi.org"]}},
  "permissions":{"deny":["Read(/data/**)","Edit(/data/**)","Read(/.nbis-safety/blocked/**)"]},"autoMemoryEnabled":false}'
strict='{"sandbox":{"network":{"strictAllowlist":true}},"autoMode":{"classifyAllShell":true}}'
setup() {   # $1: project settings, $2: user settings ('' for no file); places a readable canary
  echo "$1" > "$proj/.claude/settings.json"
  rm -f "$proj/.claude/settings.local.json" "$home/.claude/settings.json"
  [ -n "$2" ] && echo "$2" > "$home/.claude/settings.json"
  mkdir -p "$proj/.nbis-safety/blocked"
  echo 'nbis-safety canary: this file holds nothing secret' > "$proj/.nbis-safety/blocked/canary"
}
exit_is() { [ "$code" = "$1" ] || { echo "FAIL: exit $code, expected $1"; fail=1; }; }

# 1. readable canary: a run outside the sandbox says so first and never says blocked
setup "$support" "$strict"
out=$(CURL_MODE=open verify); code=$?
expect 'tested: NOT BLOCKED  reading a blocked project folder'
exit_is 1
[[ $out == note:* ]] || { echo "FAIL: the first line is not a note"; fail=1; }
refuse 'tested: blocked'
out=$(CURL_MODE=split verify)
refuse 'tested: blocked'
expect 'not tested: network'
# test folder gone altogether (a fresh clone, or it was deleted): not tested, never "blocked"
mv "$proj/.nbis-safety/blocked" "$proj/.nbis-safety/blocked.away"
out=$(CURL_MODE=split verify)
refuse 'tested: blocked  reading a blocked project folder'
expect 'not tested: reading a blocked project folder (the test file is missing'
mv "$proj/.nbis-safety/blocked.away" "$proj/.nbis-safety/blocked"
# 2, 5, 9, 11. canary hidden, as in a masked folder; support settings and strictAllowlist
rm "$proj/.nbis-safety/blocked/canary"
out=$(CURL_MODE=split verify); code=$?
expect 'tested: blocked  reading a blocked project folder'
expect 'tested: blocked  a host outside the network list'
expect 'configured: yes  sandbox on in this project'
expect 'configured: yes  network list is a hard limit'
expect 'configured: yes  memory off'
expect 'configured: yes  home is blocked for shell commands'
expect 'configured: yes  data folder 1'
exit_is 0
refuse './data'
refuse 's1.fastq'
refuse 'CANARYREAD'
refuse 'id_canary'
out=$(CURL_MODE=open verify)
expect 'tested: NOT BLOCKED  a host outside the network list'
out=$(CURL_MODE=offline verify)
expect 'not tested: network (offline'
refuse 'tested: blocked  a host'
# 10. no curl
out=$(HOME=$home PATH=$nocurl "$BASH" "$check" --verify "$proj" 2>&1)
expect 'not tested: network (curl is not installed)'
# 3. the canary's folder is not in denyRead
setup "$(jq -c '.sandbox.filesystem.denyRead -= ["./.nbis-safety/blocked"]' <<<"$support")" "$strict"
out=$(verify)
expect 'not tested: reading a blocked project folder'
# 4. sandbox off
setup "$(jq -c '.sandbox.enabled = false' <<<"$support")" "$strict"
out=$(verify); code=$?
expect 'configured: NO  sandbox on in this project'
exit_is 1
# 6. user settings not valid JSON: unknown, and the file is not printed
setup "$support" '{broken'
out=$(verify)
expect 'configured: unknown  network list is a hard limit'
refuse 'broken'
# 7. no user settings file
setup "$support" ''
out=$(verify)
expect 'configured: unknown  network list is a hard limit'
refuse 'check.sh: line'
# 8. settings.local.json turns the sandbox off
setup "$support" "$strict"
echo '{"sandbox":{"enabled":false}}' > "$proj/.claude/settings.local.json"
out=$(verify)
expect 'configured: NO  sandbox on in this project'

# probe.sh outside the sandbox (the control): every probe ok, outcomes only, and the home marker found
out=$(cd "$proj" && HOME=$home PATH="$fakebin:$PATH" CURL_MODE=open bash "$here/probe/probe.sh" data/s1.fastq 2>&1)
for p in 'ls ~/.ssh' 'read ~/.claude/settings.json' 'read canary content' 'read data file' 'write in project' \
         'write in home' 'listed host' 'unlisted host'; do expect "$p: ok"; done
refuse 's1.fastq'
refuse 'CANARYREAD'
refuse 'id_canary'
refuse 'nothing secret'
out=$(HOME=$home bash "$here/probe/probe.sh" --check-marker 2>&1)
expect 'home marker: present (removed)'
[ -e "$home/.nbis-probe-marker" ] && { echo "FAIL: --check-marker left the marker"; fail=1; }

[ "$fail" = 0 ] && echo "test-check: ok"
exit "$fail"
