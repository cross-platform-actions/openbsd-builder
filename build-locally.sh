#!/bin/bash

set -euo pipefail

OS_VERSION="$1"
ARCHITECTURE="$2"

# mkdir -p "$PROJECT_ROOT_PATH/packer_cache_backup"
# cp "$PROJECT_ROOT_PATH/packer_cache"/*.img "$PROJECT_ROOT_PATH/packer_cache_backup"

rm -rf packer_cache

PACKER_LOG=1 packer build \
  -var-file "$OS_VERSION/common.pkrvars.hcl" \
  -var-file "$ARCHITECTURE.pkrvars.hcl" \
  -var-file local-macos.pkrvars.hcl \
  openbsd.pkr.hcl
