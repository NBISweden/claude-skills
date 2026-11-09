#!/usr/bin/env bash
# Read-only check of a project before /nbis-safety:container-setup writes anything.
# Prints file names, settings keys and environment variable NAMES only, never file contents or
# variable values. The one exception is the sandbox keys under "Sandbox settings": true/false/unset.
# Usage: check-container.sh [project-dir]   (default: current directory)
# For tests, these override what is read: CHECK_ROOT (prefix for /.dockerenv and /run/.containerenv),
# CHECK_PROC (default /proc), CHECK_DOCKER_SOCK (default /var/run/docker.sock), CHECK_NET_URL
# (default https://example.com).
set -u
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
cd "${1:-.}" || exit 1
project=$(pwd -P)
# shellcheck source=../safe-setup/lib-project.sh
. "$here/../safe-setup/lib-project.sh"

proc=${CHECK_PROC:-/proc}
root=${CHECK_ROOT:-}
sock=${CHECK_DOCKER_SOCK:-/var/run/docker.sock}

check_claude_version

check_endpoint

say "== Container"
if [ -e "$root/.dockerenv" ] || [ -e "$root/run/.containerenv" ] \
   || grep -qE 'docker|containerd|kubepods|libpod|podman|lxc' "$proc/1/cgroup" 2>/dev/null; then
  say "ok: running in a container"
else
  say "NOT IN A CONTAINER: use /nbis-safety:safe-setup instead (the sandbox is the boundary there)"
fi

say "== Container boundary"
capeff=$(awk '$1=="CapEff:"{print $2}' "$proc/self/status" 2>/dev/null)
nnp=$(awk '$1=="NoNewPrivs:"{print $2}' "$proc/self/status" 2>/dev/null)
if [ -z "$capeff" ]; then say "capabilities: could not read $proc/self/status"
elif [ "$((16#$capeff))" -eq 0 ]; then say "ok: CapEff $capeff (all capabilities dropped)"
else say "WEAK: CapEff $capeff (capabilities not dropped; add --cap-drop=ALL)"
fi
case "$nnp" in
  1) say "ok: NoNewPrivs 1" ;;
  "") say "no-new-privileges: could not read $proc/self/status" ;;
  *) say "WEAK: NoNewPrivs $nnp (add --security-opt no-new-privileges)" ;;
esac
[ "$(id -u)" = 0 ] && say "WEAK: running as uid 0 (use a non-root user, docker run --user)"
say "-- mounts (source -> target; home, ~/.ssh, ~/.aws, ~/.config/gh and container sockets are flagged)"
awk -v home="$HOME" '
  { for (i = 7; i <= NF && $i != "-"; i++) ; fs = $(i + 1)
    src = $4; dst = $5; opts = ($6 ~ /(^|,)ro(,|$)/) ? "ro" : "rw"
    sockmnt = (src ~ /(docker|podman)\.sock$/ || dst ~ /(docker|podman)\.sock$/)
    if (!sockmnt && fs ~ /^(proc|sysfs|tmpfs|devpts|cgroup2?|mqueue|overlay|devtmpfs)$/) next
    if (dst ~ /^\/etc\/(resolv.conf|hostname|hosts)$/) next
    printf "mount: %s -> %s (%s)\n", src, dst, opts
    for (j = 0; j < 2; j++) {
      p = (j == 0) ? src : dst
      if (p == "/root" || p == home || p ~ /^\/home\/[^\/]+$/)
        printf "WEAK: a home directory is mounted (%s); mount only the project\n", p
      if (p ~ /\/\.ssh(\/|$)/) printf "WEAK: ~/.ssh is mounted (%s); do not mount it\n", p
      if (p ~ /\/\.aws(\/|$)/) printf "WEAK: ~/.aws is mounted (%s); do not mount it\n", p
      if (p ~ /\/\.config\/gh(\/|$)/) printf "WEAK: ~/.config/gh is mounted (%s); do not mount it\n", p
      if (p ~ /(docker|podman)\.sock$/) printf "WEAK: a container socket is mounted (%s); it gives root on the host, never mount it\n", p
    }
  }' "$proc/self/mountinfo" 2>/dev/null | awk '!seen[$0]++' || true
[ -e "$sock" ] && say "WEAK: $sock exists in the container; it gives root on the host, never mount it"

say "-- outbound network"
if ! command -v curl >/dev/null; then say "curl not installed, not tested"
elif curl -sS --max-time 5 -o /dev/null "${CHECK_NET_URL:-https://example.com}" 2>/dev/null; then
  say "OPEN: https://example.com is reachable; data or secrets in the container can be sent out"
else say "blocked: https://example.com is not reachable"
fi

say "-- environment variable names matching TOKEN|KEY|SECRET|PASSWORD (names only, never values)"
excluded="CLAUDE_CODE_MESSAGING_TOKEN"   # Claude Code's own internal variable
found=0
while read -r n; do
  case " $excluded " in *" $n "*) continue ;; esac
  say "env: $n"; found=1
done < <(compgen -e | grep -iE 'TOKEN|KEY|SECRET|PASSWORD' | sort)
[ "$found" = 0 ] && say "(none)"
say "(excluded as Claude Code internals: $excluded)"

say "== Sandbox settings (the container is the boundary; bwrap cannot run in Docker)"
# --settings has the highest precedence of the files below, so it can override them
sfile=""
if [ -r "$proc/1/cmdline" ]; then
  while IFS= read -r -d '' a; do
    if [ "${prev:-}" = --settings ]; then sfile=$a; fi
    case "$a" in --settings=*) sfile=${a#--settings=} ;; esac
    prev=$a
  done <"$proc/1/cmdline"
fi
if ! command -v jq >/dev/null; then say "jq not installed, skipped: check these files by hand"
else
  val() { jq -r --arg k "$2" '.sandbox[$k] | if . == null then "unset" else tostring end' "$1" 2>/dev/null || echo "not valid JSON"; }
  report() {   # $1: label, $2: file
    if [ -f "$2" ]; then say "$1: sandbox.enabled $(val "$2" enabled), failIfUnavailable $(val "$2" failIfUnavailable)"
    else say "$1: absent"; fi
  }
  report "--settings file${sfile:+ ($sfile)}" "${sfile:-/nonexistent}"
  [ -z "$sfile" ] && say "(no --settings argument found on PID 1's command line)"
  report "~/.claude/settings.json" ~/.claude/settings.json
  report ".claude/settings.json" .claude/settings.json
  report ".claude/settings.local.json" .claude/settings.local.json
  disabled=no
  [ -n "$sfile" ] && [ -f "$sfile" ] && [ "$(val "$sfile" enabled)" = false ] && disabled=yes
  say "--settings file disables the sandbox: $disabled"
  if [ "$disabled" = no ]; then
    for f in .claude/settings.json .claude/settings.local.json; do
      [ -f "$f" ] || continue
      if [ "$(val "$f" enabled)" = true ] || [ "$(val "$f" failIfUnavailable)" = true ]; then
        say "WARNING: $f turns the sandbox on or requires it, and the --settings file does not disable it: Claude Code exits silently at startup in a container. Add {\"sandbox\": {\"enabled\": false}} to the container-only settings file; leave the project file alone."
      fi
    done
  fi
fi

say "== Project: $project"
case "$project" in "$HOME") say "WARNING: this is your home directory, run from a project folder" ;; esac
scan_project

say "== MCP servers (names only)"
scan_mcp

say "== gitleaks"
scan_gitleaks
