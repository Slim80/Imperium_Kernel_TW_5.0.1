#!/sbin/busybox sh

BB=/sbin/busybox

# Mounting partition in RW mode

        $BB mount -o remount,rw /;
        $BB mount -o remount,rw /system;

# Fixing ROOT
if [ -e /system/priv-app/SuperSU/SuperSU.apk ]; then
	/system/xbin/daemonsu --auto-daemon &
fi;
# if [ -e /system/priv-app/Magisk/Magisk.apk ]; then
#	$BB ln -s /sbin/su /system/xbin/su
# fi;
# if [ -e /data/app/com.topjohnwu.magisk-1/base.apk ]; then
#	$BB ln -s /sbin/su /system/xbin/su
# fi;
#if [ -e /data/app/com.topjohnwu.magisk-2/base.apk ]; then
#	$BB ln -s /sbin/su /system/xbin/su
# fi;

sleep 1;

# Run Qualcomm scripts in system/etc folder if exists
if [ -e /system/etc/init.qcom.post_boot.sh ]; then
	$BB chmod 755 /system/etc/init.qcom.post_boot.sh;
	$BB sh /system/etc/init.qcom.post_boot.sh;
fi;

sleep 1;

# Create init.d folder if missing
if [ ! -d /system/etc/init.d ]; then
	$BB mkdir -p /system/etc/init.d
	$BB chmod 755 /system/etc/init.d
fi

# Cleaning
$BB rm -rf /cache/lost+found/* 2> /dev/null;
$BB rm -rf /data/lost+found/* 2> /dev/null;
$BB rm -rf /data/tombstones/* 2> /dev/null;

# Critical permissions fix
$BB chown -R root:root /tmp;
$BB chown -R root:root /sbin;
$BB chmod -R 777 /tmp/;
$BB chmod 06755 /sbin/busybox;
if [ -e /system/xbin/busybox ]; then
	$BB chmod 06755 /system/xbin/busybox;
fi

# Prop tweaks
setprop persist.adb.notify 0
setprop persist.service.adb.enable 1
setprop debug.performance.tuning 1
setprop video.accelerate.hw 1 
setprop persist.sys.ui.hw 1 
setprop logcat.live disable
setprop profiler.force_disable_ulog 1
setprop persist.service.btui.use_aptx 1

# Stop google service and restart it on boot. This remove high cpu load and ram leak!
if [ "$($BB pidof com.google.android.gms | wc -l)" -eq "1" ]; then
	$BB kill "$($BB pidof com.google.android.gms)";
fi;
if [ "$($BB pidof com.google.android.gms.unstable | wc -l)" -eq "1" ]; then
	$BB kill "$($BB pidof com.google.android.gms.unstable)";
fi;
if [ "$($BB pidof com.google.android.gms.persistent | wc -l)" -eq "1" ]; then
	$BB kill "$($BB pidof com.google.android.gms.persistent)";
fi;
if [ "$($BB pidof com.google.android.gms.wearable | wc -l)" -eq "1" ]; then
	$BB kill "$($BB pidof com.google.android.gms.wearable)";
fi;

# Google Services battery drain fixer by Alcolawl@xda
# http://forum.xda-developers.com/google-nexus-5/general/script-google-play-services-battery-t3059585/post59563859
pm enable com.google.android.gms/.update.SystemUpdateActivity
pm enable com.google.android.gms/.update.SystemUpdateService
pm enable com.google.android.gms/.update.SystemUpdateService$ActiveReceiver
pm enable com.google.android.gms/.update.SystemUpdateService$Receiver
pm enable com.google.android.gms/.update.SystemUpdateService$SecretCodeReceiver
pm enable com.google.android.gsf/.update.SystemUpdateActivity
pm enable com.google.android.gsf/.update.SystemUpdatePanoActivity
pm enable com.google.android.gsf/.update.SystemUpdateService
pm enable com.google.android.gsf/.update.SystemUpdateService$Receiver
pm enable com.google.android.gsf/.update.SystemUpdateService$SecretCodeReceiver

# Make sure that max gpu clock is set by default to 450 MHz
$BB echo 450000000 > /sys/class/kgsl/kgsl-3d0/max_gpuclk;

# Remove STweaks
$BB rm -f /system/app/HybridTweaks.apk > /dev/null 2>&1;
$BB rm -f /system/app/Hulk-Kernel sTweaks.apk > /dev/null 2>&1;
$BB rm -f /system/app/STweaks.apk > /dev/null 2>&1;
$BB rm -f /system/app/STweaks_Googy-Max.apk > /dev/null 2>&1;
$BB rm -f /system/app/GTweaks.apk > /dev/null 2>&1;
$BB rm -f /data/app/com.gokhanmoral.stweaks* > /dev/null 2>&1;
$BB rm -f /data/data/com.gokhanmoral.stweaks*/* > /dev/null 2>&1;
	
sleep 1;

# script finish here, so let me know when
rm /data/local/tmp/Imperium_LL_Kernel
touch /data/local/tmp/Imperium_LL_Kernel
echo "Imperium LL Kernel script correctly applied" > /data/local/tmp/Imperium_LL_Kernel;

$BB mount -t rootfs -o remount,ro rootfs
$BB mount -o remount,ro /system

