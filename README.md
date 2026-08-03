# Android device tree for Project Snowcastle

This is based on the HoolockLinux project, or its derivated projects.

Currently, we only support devices with internal storage support.
We have no way to tether boot Android yet.

## Available HoolockLinux derivations

- Pauli1Go: Provides touchscreen & Wi-Fi & Bluetooth & charging support for iPhone 7 series and iPad 7.
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

### Obtain firmwares via hKernelFWExtractor

1. Obtain iOS kernel using blacktop's [tool](https://github.com/blacktop/ipsw), for example: `ipsw download ipsw --device iPhone10,1 --build 20H380 --kernel`

2. Extract firmwares from the iOS kernel using [hKernelFWExtractor](https://github.com/HoolockLinux/hKernelFWExtractor).

### Obtain firmwares that are specific to Pauli1Go's HoolockLinux fork

Follow the documentation [here](https://github.com/Pauli1Go/HoolockLinux-linux-firmware).

### Build m1n1

Please check out the README file in the m1n1 repository.

### Build Android

Here we use LineageOS as example, and assuming you have already synced the platform source code.

1. Setup the build environment: `source build/envsetup.sh`.

2. Choose the `snowcastle` target: `breakfast snowcastle`.

3. Clone the kernel repository: `mkdir -p kernel/apple && git clone <URL of the kernel repository> kernel/apple/HoolockLinux`.
If this has already been done previously, skip this step.

4. Apply the needed kernel patches and kernel edits according to the table above. If this has already been done previously, skip this step.

5. Select a partition scheme to use.

- "apfs": Android will be loaded from partition images stored in APFS volume. Userdata would be stored in RAM, due to the existing APFS support on Linux not being capable of writing yet.
- "normal": Android will be loaded from normal partitions on the disk. This requires resizing APFS volume and modifying the partition table on the disk.

Execute this to select the wanted partition scheme: `export SNOWCASTLE_PARTITION_SCHEME=<wanted partition scheme>`

6. Download latest LLVM toolchain from [here](https://releases.llvm.org/), and then extract it. If this has already been done previously, skip this step.

7. Specify the full path to extracted latest LLVM toolchain. For example: `export TARGET_KERNEL_CLANG_PATH=~/Downloads/LLVM-22.1.0-Linux-X64`.

8. Put the extracted firmwares into `device/apple/snowcastle/prebuilts/firmware(/apple)?` directory.

9. If you have selected APFS partition scheme, do the following to obtain and adapt the necessary `linux-apfs-rw` module:

```
git clone https://github.com/linux-apfs/linux-apfs-rw kernel/apple/HoolockLinux-modules/linux-apfs-rw
sed -i 's|KERNEL_DIR|KERNEL_SRC|g;s|make |$(MAKE) |g;s|install:|modules_install:|g' kernel/apple/HoolockLinux-modules/linux-apfs-rw/Makefile
```

If this has already been done previously, skip this step.

10. If kernel version is v7.2+, execute this to apply a necessary patch: `repopick 494663`.

11. Put the built `m1n1.bin` to `device/apple/snowcastle/prebuilts/m1n1.bin`.

12. Start the build: `m m1n1-{boot,recovery} systemimage vendorimage`.

13. If you're using Pauli1Go's HoolockLinux fork and you want more hardware features to function on the compatible devices:

    1. Do [this](https://github.com/Pauli1Go/HoolockLinux-linux-firmware/blob/main/iphone7.md#9-prepare-private-syscfg-for-the-d111-capable-m1n1-loader) for iPhone 7,
    or [this](https://github.com/Pauli1Go/HoolockLinux-linux-firmware/blob/main/ipad7.md#10-provide-syscfg-to-the-patched-m1n1-loader) for iPad 7.
    2. Put the generated `m1n1-syscfg.payload` file into `device/apple/snowcastle/prebuilts/` directory.
    3. Start the build again.

**IMPORTANT NOTE: The m1n1 blob built after this step is usable ONLY on the device where the `syscfg.bin` is taken from. Using it on other devices may cause unpredictable bad behavior!**

### Jailbreak and enter device shell

1. Jailbreak the device with [palera1n](https://docs.website-msw.pages.dev/docs/intro/). At the post install stage, install Sileo.

2. Open Sileo app, navigate to "Search" tab, search and install `openssh`.

3. Connect to the device's shell, via SSH: `ssh mobile@<Device IP address>`.

4. Set password for user `root`: `sudo passwd root`.

5. Exit the shell, and reconnect as user `root`: `ssh root@<Device IP address>`.

### Preparations for normal partition scheme

This section is applicable only if you want Android being installed on normal partitions.
The Android firmware should be built with environment variable `SNOWCASTLE_PARTITION_SCHEME=normal`.

#### Partitioning for normal partition scheme

Here are the partitions that Android needs:

|   Name   | Minimum size |
|----------|--------------|
| system   | 3 GiB        |
| vendor   | 512 MiB      |
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

This section is applicable only if you want Android being installed in an APFS volume.
The Android firmware should be built with environment variable `SNOWCASTLE_PARTITION_SCHEME=apfs`.

1. Create the directory for storing Android images: `mkdir /private/preboot/android`.

2. Exit the SSH shell: `exit`.

3. Copy the Android images to the device: `scp system.img vendor.img root@<Device IP address>:/private/preboot/android/`.

### Boot Android

Follow [this](https://github.com/HoolockLinux/docs/blob/master/tutorials/SETUP_pongoOS.md) guide, except that we'll use the m1n1 blob from Android build output: `m1n1-boot.bin` or `m1n1-recovery.bin`.
