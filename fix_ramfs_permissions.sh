#!/bin/sh
RAMFS="/home/slim80/Scrivania/Kernel/Samsung/Imperium/Imperium_Kernel/ramfs_imperium"
chmod -R g-w $RAMFS/*
chmod g-w $RAMFS/*.rc $RAMFS/default.prop $RAMFS/sbin/*.sh
cd $RAMFS
chmod 644 file_contexts
chmod 644 se*
chmod 644 *.rc
chmod 750 init*
chmod 644 fstab*
chmod 644 default.prop
chmod 750 sbin
chmod 750 sbin/*
chmod 0755 sbin/busybox
chmod 777 sbin/*.sh

