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

# user-level deny rules that cover nothing are reported, working ones are not
expect 'permissions.deny Read(/**/.env) anchors at ~/.claude here'
expect 'permissions.deny Read(//**/*.pem) is not enforced for shell commands on Linux'
refuse 'Read(**/.env) anchors'
refuse 'Read(~/.ssh/**) anchors'

[ "$fail" = 0 ] && echo "test-check: ok"
exit "$fail"
