#!/usr/bin/env bash
set -euo pipefail
cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )/.."
source ./bin/venv.sh

echo "Installing..."
pip install -qq ".[dev]"
