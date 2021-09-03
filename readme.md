# OpenBSD Builder

This project builds the OpenBSD VM image for the
[cross-platform-actions/action](https://github.com/cross-platform-actions/action)
GitHub action. The image contains a standard OpenBSD installation without any
X components, man pages or games. It will install the following file sets:

* bsd
* bsd.mp
* bsd.rd
* baseXX.tgz
* compXX.tgz
* xbaseXX.tgz
* xfontXX.tgz
* xservXX.tgz
* xshareXX.tgz

In addition to the above file sets, the following packages are installed as well:

* sudo
* bash
* curl
* rsync

Except for the root user, there's one additional user, `runner`, which is the
user that will be running the commands in the GitHub action. This user is
allowed use `sudo` without a password.

## Architectures and Versions

The following architectures and versions are supported:

| Version | x86-64 | arm64 |
|---------|--------|-------|
| 6.8     | ✓      | ✓     |
| 6.9     | ✓      | ✓     |

## Building Locally

### Prerequisite

* [Packer](https://www.packer.io) 1.7.1 or later
* [QEMU](https://qemu.org)

### Building

1. Clone the repository:
    ```
    git clone https://github.com/cross-platform-actions/openbsd-builder
    cd openbsd-builder
    ```

2. Run `build.sh` to build the image:
    ```
    ./build.sh <version> <architecture>
    ```
    Where `<version>` and `<architecture>` are the any of the versions or
    architectures available in the above table.

The above command will build the VM image and the resulting disk image will be
at the path: `output/openbsd-6.8-amd64.qcow2`.

## Additional Information

At startup, the image will look for a second hard drive. If present and it
contains a file named `keys` at the root, it will install this file as the
`authorized_keys` file for the `runner` user. The disk is expected to be
formatted as FAT32. This is used as an alternative to a shared folder between
the host and the guest, since this is not supported by the xhyve hypervisor.
FAT32 is chosen because it's the only filesystem that is supported by both the
host (macOS) and the guest (OpenBSD) out of the box.

The VM needs to be configured with the `e1000` network device. The disk needs to
be configured with the GPT partitioning scheme. And the VM needs to be configured
to use UEFI. All this is required for the VM image to be able to run using the
xhyve hypervisor.

The qcow2 format is chosen because unused space doesn't take up any space on
disk, it's compressible and easily converts the raw format, used by xhyve.
