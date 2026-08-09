#!/bin/sh -e

SYSCFG=m1n1-syscfg.payload
if [ ! -f "$SYSCFG" ]; then
	echo "Warning: $SYSCFG does not exist"
	SYSCFG=
fi

cat m1n1.bin m1n1-vars-boot.txt dtb.img $SYSCFG kernel ramdisk.img > m1n1-boot.bin
cat m1n1.bin m1n1-vars-boot.txt dtb.img $SYSCFG kernel ramdisk-recovery.img > m1n1-recovery.bin
