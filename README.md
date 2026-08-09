# Android device tree for Project Snowcastle

This is based on the HoolockLinux project, or its derivated projects.

Currently, we only support devices with internal storage support.
We have no way to tether boot Android yet.

**WARNING: Do NOT distribute builds with any Apple components included, such as the firmware files! Doing so violates Apple's EULA.**

## Available HoolockLinux derivations

- Pauli1Go: Provides touchscreen & Wi-Fi & Bluetooth & charging support for iPhone 7 Plus and iPad 7.
Due to the fact that the effort involves assistance from AI, the HoolockLinux developers does not accept contribution with it.

| Name | Homepage | Kernel URL | m1n1 URL |
|------|----------|------------|----------|
| Original | https://github.com/HoolockLinux | https://github.com/HoolockLinux/linux | https://github.com/HoolockLinux/m1n1 |
| Pauli1Go | https://github.com/Pauli1Go?tab=repositories | https://github.com/Pauli1Go/HoolockLinux | https://github.com/Pauli1Go/m1n1 |

## Kernel edits

- After applying kernel patches specified below, on `mm/Kconfig`, on config option `MEMFD_ASHMEM_SHIM`, remove the dependency on `ASHMEM_C`.

## Kernel patches

For recent Linux kernel versions:

| Commit name | Purpose | Source |
|-------------|---------|--------|
| `ANDROID: usb: gadget: configfs: Add Uevent to notify userspace` | Fixes USB in normal mode | https://android.googlesource.com/kernel/common-patches/+/refs/heads/main-kernel/android-mainline/ANDROID-usb-gadget-configfs-Add-Uevent-to-notify-userspace.patch |
| `ANDROID: mm/memfd-ashmem-shim: Introduce shim layer` | Fixes graphics output via framebuffer | https://android.googlesource.com/kernel/common-patches/+/refs/heads/main-kernel/android-mainline/ANDROID-mm-memfd-ashmem-shim-Introduce-shim-layer.patch |
| `ANDROID: mm: shmem: Use memfd-ashmem-shim ioctl handler"` | Fixes graphics output via framebuffer | https://android.googlesource.com/kernel/common-patches/+/refs/heads/main-kernel/android-mainline/ANDROID-mm-shmem-Use-memfd-ashmem-shim-ioctl-handler.patch |
| `HACK: selinux: Force permissive when androidboot.selinux=permissive` | Guess :P | https://github.com/LineageOS/android_kernel_virt_virtio/commit/a723c1431987aec6e44f5ef20c9424a95727adf8 |

## How-to

### Build m1n1

Please check out the README file in the m1n1 repository.

### Prepare Android build dependencies

Here we use LineageOS as example, and assuming you have already synced the platform source code.
These instructions are NOT guaranteed to work for any other Android distributions.

1. Setup the build environment: `source build/envsetup.sh`.

2. Select the `snowcastle` target device: `breakfast snowcastle`. This step will automatically clone this device tree.

3. Clone the kernel repository: `mkdir -p kernel/apple && git clone <URL of the kernel repository> kernel/apple/HoolockLinux`.

4. Apply the needed kernel patches and kernel edits according to the table above. If this has already been done previously, skip this step.

5. Download latest LLVM toolchain from [here](https://releases.llvm.org/), and then extract it. If this has already been done previously, skip this step.

6. Do the following to obtain and adapt the necessary `linux-apfs-rw` kernel module:

```
git clone https://github.com/linux-apfs/linux-apfs-rw kernel/apple/HoolockLinux-modules/linux-apfs-rw
sed -i 's|KERNEL_DIR|KERNEL_SRC|g;s|make |$(MAKE) |g;s|install:|modules_install:|g' kernel/apple/HoolockLinux-modules/linux-apfs-rw/Makefile
```

7. If kernel version is v7.2+, execute this to apply a necessary patch: `repopick 494663`.

8. Download `ipsw_<VERSION>_linux_arm64.tar.gz` from the [ipsw releases](https://github.com/blacktop/ipsw/releases) page,
and extract the `ipsw` file inside it to `device/apple/snowcastle/prebuilts/ipsw/ipsw`.

9. Download utilities source code and put these to respective paths, as described on the table below:

| Source | Destination |
|--------|-------------|
| https://github.com/corellium/projectsandcastle/raw/refs/heads/master/hcdpack/hcdpack.c | `device/apple/snowcastle/utilities/hcdpack/hcdpack.c` |
| https://github.com/HoolockLinux/hKernelFWExtractor | `device/apple/snowcastle/utilities/hKernelFWExtractor/hKernelFWExtractor` |
| https://github.com/Pauli1Go/HoolockLinux-linux-firmware/tree/main/makez2fw | `device/apple/snowcastle/utilities/makez2fw/makez2fw` |

### Build Android

Here we use LineageOS as example, and assuming you have already synced the platform source code.
These instructions are NOT guaranteed to work for any other Android distributions.

1. Setup the build environment: `source build/envsetup.sh`.

2. Select a partition scheme to use.

- `apfs`: Android will be loaded from partition images stored in an APFS volume. Userdata would be stored in RAM, due to the existing APFS support on Linux is not capable of writing yet.
- `normal`: Android will be loaded from normal partitions on the disk. This requires resizing APFS volume and modifying the partition table on the disk.

Execute this to select the wanted partition scheme: `export SNOWCASTLE_PARTITION_SCHEME=<wanted partition scheme>`

3. Select the `snowcastle` target device: `breakfast snowcastle`.

4. Specify the full path to extracted latest LLVM toolchain. For example: `export TARGET_KERNEL_CLANG_PATH=~/Downloads/LLVM-22.1.0-Linux-X64`.

5. Start the build: `m snow`.

### Build m1n1 blobs

1. Enter the build output directory (`out/target/product/snowcastle`, or extracted snowcastle package), which contains these files:
`dtb.img`, `kernel`, `ramdisk.img`, `ramdisk-recovery.img`
`m1n1-vars-boot.txt`, `m1n1-vars-recovery.txt`,
`make-m1n1-blobs.bat`, `make-m1n1-blobs.sh`.

2. If the target device is iPhone 7 Plus, and Pauli1Go's HoolockLinux fork is used, please obtain `m1n1-syscfg.payload` for the device, by following the instructions
[here](https://github.com/Pauli1Go/HoolockLinux-linux-firmware/blob/main/iphone7.md#9-prepare-private-syscfg-for-the-d111-capable-m1n1-loader).

**IMPORTANT: With this step, the output m1n1 blob will be usable for only the exact device where the SysCfg was obtained from!**
**Using m1n1 blob with SysCfg from other devices is UNTESTED, and may produce unexpectable bad behavior.**

3. Execute script to build m1n1 blobs: `make-m1n1-blobs.bat` (Windows), or `make-m1n1-blobs.sh` (Linux).

### Jailbreak and enter device shell

1. Jailbreak the device with [palera1n](https://docs.website-msw.pages.dev/docs/intro/). At the post install stage, install Sileo.

2. Open Sileo app, navigate to "Search" tab, search and install `openssh`.

3. Connect to the device's shell, via SSH: `ssh mobile@<Device IP address>`.

4. Set password for user `root`: `sudo passwd root`.

5. Exit the shell, and reconnect as user `root`: `ssh root@<Device IP address>`.

### Preparations for normal partition scheme

This section is applicable only if you want Android to be installed on normal partitions.
The Android images should be built with environment variable `SNOWCASTLE_PARTITION_SCHEME=normal`.

#### Partitioning for normal partition scheme

Here are the partitions that Android requires:

|   Name   | Minimum size |
|----------|--------------|
| system   | 3 GiB        |
| vendor   | 256 MiB      |
| metadata | 16 MiB       |
| userdata | 2 GiB        |

1. Follow [this](https://github.com/HoolockLinux/docs/blob/master/tools/README.md) guide to resize APFS container to a smaller size that frees enough space for Android partitions.

2. Follow [this](https://github.com/HoolockLinux/docs/blob/master/tutorials/gdisk.md) guide to resize the APFS partition and create partitions for Android. Note that the gdisk command `c` in main menu can be used to rename a partition.

#### Flashing for normal partition scheme

1. Follow [this](#boot-android), pick the m1n1 blob `m1n1-recovery.bin`.

2. Wait for the device to enter Android recovery mode.

3. Perform Android's Factory Reset.

4. Enter fastbootd mode, and flash the built `system.img` and `vendor.img` via fastboot.

### Preparation and Flashing for APFS partition scheme

This section is applicable only if you want Android to be installed in an APFS volume.
The Android images should be built with environment variable `SNOWCASTLE_PARTITION_SCHEME=apfs`.

1. Create the directory for storing Android images: `mkdir -p /private/preboot/android/firmware`.

2. Exit the SSH shell: `exit`.

3. Copy the Android images to the device: `scp system.img vendor.img vendor_dlkm.img root@<Device IP address>:/private/preboot/android/`.

### Boot Android

Follow [this](https://github.com/HoolockLinux/docs/blob/master/tutorials/SETUP_pongoOS.md) guide, except that we'll use the m1n1 blob from Android build output: `m1n1-boot.bin` or `m1n1-recovery.bin`.
