#!/bin/sh
export KERNELDIR=`readlink -f .`
export PARENT_DIR=`readlink -f ..`
export ARCH=arm
export SUBARCH=arm
export CCOMPILE=$CROSS_COMPILE
export ccache=ccache
export USE_SEC_FIPS_MODE=true
export KCONFIG_NOTIMESTAMP=true
export ENABLE_GRAPHITE=true
export CROSS_COMPILE=/home/slim80/Scrivania/Kernel/Compilatori/UBERTC-arm-eabi-5.3/bin/arm-eabi-

KERNELDIR="/home/slim80/Scrivania/Kernel/Samsung/Imperium_Kernel"
IMAGE="/home/slim80/Scrivania/Kernel/Samsung/Imperium_Kernel/arch/arm/boot"
RAMFS="/home/slim80/Scrivania/Kernel/Samsung/Imperium_Kernel/ramfs_imperium"
BUILDEDKERNEL="/home/slim80/Scrivania/Kernel/Samsung/Imperium_Kernel/1_Imperium"

rm -f $IMAGE/*.cmd
rm -f $IMAGE/zImage*.*
rm -f $IMAGE/.zImage*.*
find -name '*.ko' -exec rm -rf {} \;
rm -f $BUILDEDKERNEL/Builded_Kernel/boot.img
rm -rf $KERNELDIR/ramfs_imperium.cpio
rm -rf $KERNELDIR/ramfs_imperium.cpio.gz

make clean
make distclean
ccache -C
