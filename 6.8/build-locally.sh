#!/bin/bash

set -euo pipefail

SCRIPT_PATH="$(cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P)"
PROJECT_ROOT_PATH=$(dirname "$SCRIPT_PATH")

# mkdir -p "$PROJECT_ROOT_PATH/packer_cache_backup"
# cp "$PROJECT_ROOT_PATH/packer_cache"/*.img "$PROJECT_ROOT_PATH/packer_cache_backup"

rm -rf "$PROJECT_ROOT_PATH/packer_cache"

PACKER_LOG=1 packer build \
  -var-file "$SCRIPT_PATH/local-macos-amd64.pkrvars.hcl" \
  -var-file "$SCRIPT_PATH/common-amd64.pkrvars.hcl" \
  "$PROJECT_ROOT_PATH/openbsd.pkr.hcl"
