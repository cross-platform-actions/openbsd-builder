#!/bin/bash

set -xeuo pipefail

OBSD_ARCH="${1:-amd64}"
LOCAL_ARCH="${2:-x86-64}"

snap_line="$(curl https://cdn.openbsd.org/pub/OpenBSD/snapshots/${OBSD_ARCH}/SHA256.sig 2>/dev/null | grep miniroot)"
snap_sum="$(echo $snap_line | awk '{ print $NF; }')"
snap_num="$(echo $snap_line | grep -Po 'miniroot\K(\d{2})')"

echo "${snap_sum}" > checksum

echo "checksum = \"sha256:${snap_sum}\"" > "var_files/snapshots/${LOCAL_ARCH}.pkrvars.hcl"
echo "os_number = \"${snap_num}\"" >> "var_files/snapshots/${LOCAL_ARCH}.pkrvars.hcl"
