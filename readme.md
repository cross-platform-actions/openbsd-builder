# OpenBSD Builder

This project builds the OpenBSD VM image for the
[cross-platform-actions/action](https://github.com/cross-platform-actions/action)
GitHub action. The image contains a standard OpenBSD installation without any
 man pages or games. It will install the following file sets:

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
| 7.1     | ✓      | ✓     |
| 7.2     | ✓      | ✓     |
| 7.3     | ✓      | ✓     |
| 7.4     | ✓      | ✓     |
| 7.5     | ✓      | ✓     |
| 7.6     | ✓      | ✓     |
| 7.7     | ✓      | ✓     |
| 7.8     | ✓      | ✓     |
| 7.9     | ✓      | ✓     |

## Building Locally

### Prerequisite

####  [UEFI firmware](https://github.com/tianocore/edk2)

This needs to be located at `resources/ovmf.fd`. Copy the `OVMF.fd` for it's
install location to `resources/ovmf.fd`.

* **Ubuntu** - Install the [`ovmf`](https://packages.ubuntu.com/jammy/ovmf) package.
* **Fedora** - Install the [`edk2-ovmf`](https://fedora.pkgs.org/34/fedora-x86_64/edk2-ovmf-20200801stable-4.fc34.noarch.rpm.html) package.
* **macOS** - Copy the `OVMF.fd` file from a Linux machine

#### Other

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

    To target a snapshot, override the `checksum` variable manually by
    specifying `-var checksum=<checksum>` at the end when invoking the `build.sh`
    script. You can find the appropriate checksum by looking at the SHA256 file
    for `miniroot<version>.img` on [an OpenBSD mirror](https://www.openbsd.org/ftp.html).

    ```
    ./build.sh <version> <architecture> -var checksum=<checksum>
    ```

    On non-macOS platforms the `display` variable needs to be overridden by
    specifying `-var display=gtk` or `-var display=sdl` at the end when invoking
    the `build.sh` script:

    ```
    ./build.sh <version> <architecture> -var display=gtk
    ```

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

## Contributing

### Updating the Changelog

The changelog is maintained in the [changelog.md](changelog.md) file, following
the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format. The
changelog is updated incrementally. That is, for every new feature or bugfix,
add an entry to the changelog under the `[Unreleased]` section using an
appropriate sub header (`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`,
or `Security`).

For example, when adding a new feature:

```markdown
## [Unreleased]
### Added
- Short description of the new feature
```

Entries under these sub headers determine the semantic version bump when the
next release is cut with [relog](https://github.com/jacob-carlborg/relog).

### Creating a New Release

Releases are cut with [relog](https://github.com/jacob-carlborg/relog), driven
by the `[Unreleased]` section of `changelog.md`. relog derives the next
version from the sub headers under `[Unreleased]`:

* `### Fixed` only -> patch bump
* `### Added`, `### Changed`, `### Deprecated` -> minor bump
* `### Removed` (or "Breaking" anywhere in the section) -> major bump

To cut a release, from a clean `master` working tree, run:

```
relog
```

To preview the changes without modifying anything:

```
relog --dry-run
```

To override the auto-detected version:

```
relog X.Y.Z
```

relog rewrites the changelog, commits the result, creates an annotated `vX.Y.Z`
tag, and prompts before pushing. Pushing the `vX.Y.Z` tag triggers the GitHub
Actions workflow defined in
[`.github/workflows/build.yml`](.github/workflows/build.yml), which builds the
VM images and, in the "Create Release" step, creates a draft GitHub release
using the newly added changelog section as the release notes. Review the draft
release on GitHub and publish it.
