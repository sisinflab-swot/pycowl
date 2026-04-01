#!/usr/bin/env bash
set -euo pipefail
cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )/.."

VENV_DIR=".venv"
[ -d "$VENV_DIR" ] && VENV_EXISTS=true || VENV_EXISTS=false

if $VENV_EXISTS; then
    echo "Found existing venv: $VENV_DIR"
else
    echo "Creating venv: $VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi

[ -d "$VENV_DIR/bin" ] && source "$VENV_DIR/bin/activate" || source "$VENV_DIR/Scripts/activate"

if $VENV_EXISTS; then
    echo "Cleaning up old install..."
    pip uninstall -qqy cowl
    python setup.py clean
fi

echo "Building and installing..."
pip install -qq -e ".[dev]"

echo "Testing..."
pytest -q --tb=short
