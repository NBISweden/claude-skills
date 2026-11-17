#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
chmod +x cluster-ssh
