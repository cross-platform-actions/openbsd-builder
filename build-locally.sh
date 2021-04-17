#!/bin/bash

set -euo pipefail

OS_VERSION="$1"
ARCHITECTURE="$2"

# mkdir -p packer_cache_backup
# cp packer_cache/*.img packer_cache_backup

rm -rf packer_cache

PACKER_LOG=1 packer build \
  -var-file "var_files/common.pkrvars.hcl" \
  -var-file "var_files/$OS_VERSION/common.pkrvars.hcl" \
  -var-file "var_files/$ARCHITECTURE.pkrvars.hcl" \
  -var-file var_files/local-macos.pkrvars.hcl \
  openbsd.pkr.hcl
