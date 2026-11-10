#!/usr/bin/env bash
set -eu
# The support project, what safe-setup writes for it (settings, canary), and the probe.
# The probe is copied in because the sandbox hides the plugin's own folder when it is under home.
here=$(dirname "$0")
cp -R "$here/../safe-setup-support/files/." .
cp -R "$here/files/." .
cp "$here/../../tests/probe/probe.sh" .
