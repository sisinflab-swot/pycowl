#!/usr/bin/env bash
set -euo pipefail
cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )/.."
source ./bin/venv.sh

echo "Installing build dependencies..."
pip install -qq build twine

echo "Building source distribution..."
python -m build --sdist

echo "Checking distribution..."
twine check dist/*

echo "Testing..."
pip install -qq dist/*.tar.gz pytest
pytest
