#!/usr/bin/env bash
set -euo pipefail

cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )/.."
source ./bin/venv.sh

if pip show cowl -qq; then
    echo "Cleaning up old install..."
    pip uninstall -qqy cowl
    python setup.py clean
fi

echo "Building and installing..."
pip install -qq -e ".[dev]"
