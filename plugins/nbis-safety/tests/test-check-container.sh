#!/usr/bin/env bash
# check-container.sh must report container findings and sandbox settings by name, never print
# file contents or environment variable values, and say whether --settings disables the sandbox.
set -u
here=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

home=$tmp/home
proj=$home/work/proj
fake=$tmp/proc
mkdir -p "$proj/data" "$proj/.claude" "$fake/1" "$fake/self" "$home/.claude"
echo 'API_KEY=canary-secret-value' > "$proj/.env"
printf '@r1\nCANARYREAD\n+\nIIIIIIIIII\n' > "$proj/data/s1.fastq"
echo '{"sandbox":{"enabled":true,"failIfUnavailable":true}}' > "$proj/.claude/settings.json"
printf 'Name:\tclaude\nCapEff:\t00000000a80425fb\nNoNewPrivs:\t0\n' > "$fake/self/status"
cat > "$fake/self/mountinfo" <<M
30 1 259:2 /home/tester/claude /work rw,relatime - ext4 /dev/sda1 rw
31 1 259:2 /home/tester/.ssh /root/.ssh ro,relatime - ext4 /dev/sda1 rw
32 1 0:25 /docker.sock /var/run/docker.sock rw,nosuid - tmpfs tmpfs rw
33 1 0:99 / /proc rw,nosuid - proc proc rw
M
printf '12:memory:/docker/abc\n' > "$fake/1/cgroup"

run() {   # $1: path of the --settings file
  printf 'claude\0--settings\0%s\0' "$1" > "$fake/1/cmdline"
  HOME=$home MY_API_TOKEN=canary-env-value CHECK_PROC=$fake CHECK_ROOT=$tmp/none \
    CHECK_DOCKER_SOCK=$fake/1/cgroup CHECK_NET_URL=http://127.0.0.1:1 \
    bash "$here/../skills/container-setup/check-container.sh" "$proj" 2>&1
}
fail=0
expect() { grep -qF -- "$1" <<<"$out" || { echo "FAIL: output lacks '$1'"; fail=1; }; }
refuse() { grep -qF -- "$1" <<<"$out" && { echo "FAIL: output contains '$1'"; fail=1; }; }

echo '{"permissions":{}}' > "$tmp/settings-plain.json"
out=$(run "$tmp/settings-plain.json")
expect 'ok: running in a container'
expect './.env'
expect './data'
refuse 'canary-secret-value'
refuse 'CANARYREAD'
refuse 'canary-env-value'
expect 'env: MY_API_TOKEN'
expect 'WEAK: CapEff 00000000a80425fb'
expect 'WEAK: NoNewPrivs 0'
expect 'WEAK: ~/.ssh is mounted (/root/.ssh)'
expect 'WEAK: a container socket is mounted (/var/run/docker.sock)'
expect 'exists in the container'
expect 'blocked: https://example.com is not reachable'
expect '.claude/settings.json: sandbox.enabled true, failIfUnavailable true'
expect '--settings file disables the sandbox: no'
expect 'WARNING: .claude/settings.json turns the sandbox on'

echo '{"sandbox":{"enabled":false}}' > "$tmp/settings-off.json"
out=$(run "$tmp/settings-off.json")
expect '--settings file disables the sandbox: yes'
refuse 'WARNING: .claude/settings.json turns the sandbox on'

rm -rf "$fake/1/cgroup"; rm -f "$tmp/none"
mkdir -p "$tmp/none"; echo 'plain' > "$fake/1/cgroup"
out=$(run "$tmp/settings-off.json")
expect 'NOT IN A CONTAINER'

[ "$fail" = 0 ] && echo "test-check-container: ok"
exit "$fail"
