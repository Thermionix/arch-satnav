#!/bin/bash

git clone git://git.denx.de/u-boot.git
cd u-boot
make CROSS_COMPILE=arm-frc-linux-gnueabi- Linksprite_pcDuino3_Nano_defconfig
echo "CONFIG_UBOOT_LOGO_ENABLE=n" >> .config
make CROSS_COMPILE=arm-frc-linux-gnueabi-

mkdir -p ../u-boot-output
cp u-boot-sunxi-with-spl.bin spl/sunxi-spl.bin u-boot.img ../u-boot-output

cp u-boot.dtb ../u-boot-output/sun7i-a20-pcduino3-nano.dtb

# Zero and Write the new bootloader to the sdcard:
sudo dd if=/dev/zero of=/dev/sdX bs=1M count=8
sudo dd if=u-boot-sunxi-with-spl.bin of=/dev/sdX bs=1024 seek=8
sync

# Also copy sun7i-a20-pcduino3-nano.dtb into /boot/dtbs


#  community/uboot-tools 2014.10-1	/usr/bin/mkimage


## cat boot.cmd
#setenv bootargs console=ttyS0 root=/dev/mmcblk0p1 rootwait panic=10 ${extra}
#ext2load mmc 0 0x43000000 boot/script.bin
#ext2load mmc 0 0x48000000 boot/uImage
#bootm 0x48000000


# mkimage -C none -A arm -T script -d boot.cmd boot.scr



# https://github.com/torvalds/linux/blob/master/arch/arm/boot/dts/sun7i-a20-pcduino3-nano.dts

# sun7i-a20-pcduino3-nano.dtb
#/boot/uImage

# add to /boot/dtbs

