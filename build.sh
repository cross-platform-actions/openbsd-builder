#!/bin/bash

set -euxo pipefail

OS_VERSION="$1"; shift
ARCHITECTURE="$1"; shift

flags=(
  "-var"      "os_version=$OS_VERSION"
  "-var-file" "var_files/common.pkrvars.hcl"
  "-var-file" "var_files/$ARCHITECTURE.pkrvars.hcl"
)

if [ -e "var_files/$OS_VERSION/$ARCHITECTURE.pkrvars.hcl" ]; then
  flags+=("-var-file")
  flags+=("var_files/$OS_VERSION/$ARCHITECTURE.pkrvars.hcl")
fi

packer build "${flags[@]}" "$@" openbsd.pkr.hcl
