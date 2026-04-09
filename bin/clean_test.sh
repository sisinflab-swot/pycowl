#!/usr/bin/env bash
set -euo pipefail
cd -P -- "$( dirname -- "${BASH_SOURCE[0]}" )/.."

source ./bin/clean_build.sh
source ./bin/test.sh
