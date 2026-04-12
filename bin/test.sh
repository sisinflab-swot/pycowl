#!/usr/bin/env bash
set -euo pipefail
cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )/.."
source ./bin/venv.sh

echo "Testing..."
pytest -q --tb=short

echo "Running examples..."
cd examples
for example in [[:alpha:]]*.py; do
    echo "Running $example..."
    python "$example"
done
