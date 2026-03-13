#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )
VENV_DIR="$ROOT_DIR/.venv"

if [ -d "$VENV_DIR" ]; then
    echo "Found existing venv: $VENV_DIR"
else
    echo "Creating venv: $VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi

[ -d "$VENV_DIR/bin" ] && source "$VENV_DIR/bin/activate" || source "$VENV_DIR/Scripts/activate"

echo "Cleaning up old install..."
pip uninstall -qqy cowl
python "$ROOT_DIR/setup.py" clean

echo "Installing package..."
pip install -qq -e "$ROOT_DIR"

echo "Testing..."
python -m unittest discover -s "$ROOT_DIR/tests"
