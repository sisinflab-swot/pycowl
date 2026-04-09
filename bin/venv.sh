#!/usr/bin/env bash
set -euo pipefail

if [ ! ${VIRTUAL_ENV:-} ]; then
    VENV_DIR=".venv"
    [ -d "$VENV_DIR" ] && VENV_EXISTS=true || VENV_EXISTS=false

    if $VENV_EXISTS; then
        echo "Found existing venv: $VENV_DIR"
    else
        echo "Creating venv: $VENV_DIR"
        python3 -m venv "$VENV_DIR"
    fi

    [ -d "$VENV_DIR/bin" ] && source "$VENV_DIR/bin/activate" || source "$VENV_DIR/Scripts/activate"
fi
