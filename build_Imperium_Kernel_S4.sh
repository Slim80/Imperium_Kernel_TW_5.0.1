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
export CROSS_COMPILE=/home/slim80/Scrivania/Kernel/Compilatori/DespairFactor-arm-eabi-5.x/bin/arm-eabi-

KERNELDIR="/home/slim80/Scrivania/Kernel/Samsung/Imperium_Kernel"
IMAGE="/home/slim80/Scrivania/Kernel/Samsung/Imperium_Kernel/arch/arm/boot"
RAMFS="/home/slim80/Scrivania/Kernel/Samsung/Imperium_Kernel/ramfs_imperium"
BUILDEDKERNEL="/home/slim80/Scrivania/Kernel/Samsung/Imperium_Kernel/1_Imperium"
VERSION=5.7
find -name '*.ko' -exec rm -rf {} \;

rm -rf $KERNELDIR/ramfs_imperium.cpio
rm -rf $KERNELDIR/ramfs_imperium.cpio.gz

rm -f $BUILDEDKERNEL/Builded_Kernel/boot.img
rm -f $BUILDEDKERNEL/Builded_Kernel/system/lib/modules/*

make imperium_defconfig VARIANT_DEFCONFIG=jf_eur_defconfig SELINUX_DEFCONFIG=selinux_defconfig
make -j4

sh ./fix_ramfs_permissions.sh

cd $RAMFS
find . | cpio -H newc -o | gzip > $KERNELDIR/ramfs_imperium.cpio.gz

cd $KERNELDIR
./scripts/mkbootimg --kernel $IMAGE/zImage --ramdisk $KERNELDIR/ramfs_imperium.cpio.gz --base 0x80200000 --pagesize 2048 --kernel_offset 0x00008000 --ramdisk_offset 0x02000000 --tags_offset 0x00000100 --cmdline 'console=null androidboot.hardware=qcom user_debug=23 msm_rtb.filter=0x3F ehci-hcd.park=3' -o $BUILDEDKERNEL/Builded_Kernel/boot.img

find -name '*.ko' -exec cp -av {} $BUILDEDKERNEL/Builded_Kernel/system/lib/modules/ \;
cd $BUILDEDKERNEL/Builded_Kernel/
zip -r ../Imperium_LL_Kernel_v$VERSION.zip .

echo "* Done! *"
echo "* Imperium Kernel v$VERSION is ready to be flashed *"
