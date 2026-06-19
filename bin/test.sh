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

echo "Running CLI tools..."
src_file="./res/pizza.owl"
dest_file="$(mktemp)"
pycowl convert "$src_file" -d protocowl -o "$dest_file"
pycowl diff "$src_file" "$dest_file" --ignore-prefixes
pycowl stats "$src_file"
