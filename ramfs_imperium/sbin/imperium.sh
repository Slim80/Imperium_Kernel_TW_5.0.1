#!/sbin/busybox sh

BB=/sbin/busybox

# Mounting partition in RW mode

OPEN_RW()
{
        $BB mount -o remount,rw /;
        $BB mount -o remount,rw /system;
}
OPEN_RW;

# Fixing ROOT
if [ -f /system/priv-app/SuperSU/SuperSU.apk ]; then
	/system/xbin/daemonsu --auto-daemon &
fi;
if [ -f /system/priv-app/Magisk/Magisk.apk ]; then
	/system/xbin/daemonsu --auto-daemon &
fi;
if [ -f /data/app/com.topjohnwu.magisk-1/base.apk ]; then
	$BB ln -s /sbin/su /system/xbin/su
fi;
if [ -f /data/app/com.topjohnwu.magisk-2/base.apk ]; then
	$BB ln -s /sbin/su /system/xbin/su
fi;

sleep 1;

# Run Qualcomm scripts in system/etc folder if exists
if [ -f /system/etc/init.qcom.post_boot.sh ]; then
	$BB chmod 755 /system/etc/init.qcom.post_boot.sh;
	$BB sh /system/etc/init.qcom.post_boot.sh;
fi;

sleep 1;

OPEN_RW;

# Create init.d folder if missing
if [ ! -d /system/etc/init.d ]; then
	$BB mkdir -p /system/etc/init.d
	$BB chmod 755 /system/etc/init.d
fi

# Symlink
if [ ! -e /cpufreq ]; then
	$BB ln -s /sys/devices/system/cpu/cpu0/cpufreq/ /cpufreq;
	$BB ln -s /sys/devices/system/cpu/cpufreq/ /cpugov;
fi;

# Cleaning
$BB rm -rf /cache/lost+found/* 2> /dev/null;
$BB rm -rf /data/lost+found/* 2> /dev/null;
$BB rm -rf /data/tombstones/* 2> /dev/null;

OPEN_RW;

CRITICAL_PERM_FIX()
{
	# critical Permissions fix
	$BB chown -R root:root /tmp;
	$BB chown -R root:root /res;
	$BB chown -R root:root /sbin;
	$BB chown -R root:root /lib;
	$BB chmod -R 777 /tmp/;
	$BB chmod -R 775 /res/;
	$BB chmod 06755 /sbin/busybox;
	$BB chmod 06755 /system/xbin/busybox;
}
CRITICAL_PERM_FIX;

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

# Scheduler
	$BB echo "$int_scheduler" > /sys/block/mmcblk0/queue/scheduler;
	$BB echo "$int_read_ahead_kb" > /sys/block/mmcblk0/bdi/read_ahead_kb;
	$BB echo "$ext_scheduler" > /sys/block/mmcblk1/queue/scheduler;
	$BB echo "$ext_read_ahead_kb" > /sys/block/mmcblk1/bdi/read_ahead_kb;

# CPU
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor;
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_governor;
	$BB echo "$scaling_governor_cpu0" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu1/cpufreq/scaling_min_freq;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu2/cpufreq/scaling_min_freq;
	$BB echo "$scaling_max_freq" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_max_freq;
	$BB echo "$scaling_min_freq" > /sys/devices/system/cpu/cpu3/cpufreq/scaling_min_freq;

# Fix critical perms again
	CRITICAL_PERM_FIX;
	
sleep 1;

# script finish here, so let me know when
rm /data/local/tmp/Imperium_LL_Kernel
touch /data/local/tmp/Imperium_LL_Kernel
echo "Imperium LL Kernel script correctly applied" > /data/local/tmp/Imperium_LL_Kernel;

$BB mount -t rootfs -o remount,ro rootfs
$BB mount -o remount,ro /system

