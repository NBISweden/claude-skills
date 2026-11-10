#!/usr/bin/env bash
set -eu
# Reuse the support case's code and data, not its README or .env.
src="$(dirname "$0")/../safe-setup-support/files"
cp -R "$src/src" "$src/data" .
