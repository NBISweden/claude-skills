#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/../safe-setup-support/files/." .
mkdir -p .claude
echo '{"sandbox":{"enabled":false}}' > .claude/settings.json
