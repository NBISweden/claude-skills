#!/usr/bin/env bash
# The eval's stub ssh must never run the command it is given, must answer
# squeue and ls with canned output, and must report the job COMPLETED from the
# third squeue call on, so a polling loop in the eval ends.
set -u
here=$(cd "$(dirname "$0")" && pwd)
stub=$here/../evals/hpc-cluster-safety-stuck-run/files/cluster-ssh
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp" || exit 1
fail=0

bash "$stub" "touch $tmp/ran" >/dev/null
[ ! -e "$tmp/ran" ] || { echo "FAIL: stub ran the command"; fail=1; }
bash "$stub" "ls /proj/demo/run1" | grep -q '^work$' || { echo "FAIL: no canned ls"; fail=1; }
bash "$stub" "squeue -u me" | grep -q RUNNING || { echo "FAIL: first squeue not RUNNING"; fail=1; }
bash "$stub" "squeue -u me" | grep -q RUNNING || { echo "FAIL: second squeue not RUNNING"; fail=1; }
bash "$stub" "sacct -j 4242" | grep -q COMPLETED || { echo "FAIL: third poll not COMPLETED"; fail=1; }

[ "$fail" = 0 ] && echo "cluster-ssh stub ok"
exit "$fail"
