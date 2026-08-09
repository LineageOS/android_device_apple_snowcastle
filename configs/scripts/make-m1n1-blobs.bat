@echo off
setlocal enableextensions

set "SYSCFG=m1n1-syscfg.payload"

if not exist "%SYSCFG%" (
    echo Warning: %SYSCFG% does not exist
    copy /b m1n1.bin + m1n1-vars-boot.txt + dtb.img + kernel + ramdisk.img m1n1-boot.bin
    copy /b m1n1.bin + m1n1-vars-recovery.txt + dtb.img + kernel + ramdisk-recovery.img m1n1-recovery.bin
) else (
    copy /b m1n1.bin + m1n1-vars-boot.txt + dtb.img + "%SYSCFG%" + kernel + ramdisk.img m1n1-boot.bin
    copy /b m1n1.bin + m1n1-vars-recovery.txt + dtb.img + "%SYSCFG%" + kernel + ramdisk-recovery.img m1n1-recovery.bin
)

pause
