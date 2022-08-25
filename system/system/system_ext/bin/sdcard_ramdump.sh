#!/system/bin/sh

crash_handler=`getprop persist.vendor.lge.service.crash.enable`
boot_count=`getprop ro.boot.vendor.lge.boot.count`

case "$crash_handler" in
    "1")
	for j in 1 2 3 4 5 6 7 8
	do
	    sleep 5
#	    folder_name=`ls /storage/ | grep -`
	    folder_name=`ls /mnt/media_rw/ | grep -`
	    if [ ! -z "$folder_name" ]; then
		echo "sdcard_ramdump_backup $folder_name" > /dev/kmsg
		break
	    fi
	done
	for i in 1 2 3 4 5 6 7 8 9 10
	do
#	    if [ -f /storage/$folder_name/$i/OCIMEM.BIN ] && [ -f /storage/$folder_name/rdcookie.txt ]; then
	    if [ -f /mnt/media_rw/$folder_name/$i/OCIMEM.BIN ] && [ -f /mnt/media_rw/$folder_name/rdcookie.txt ]; then
		echo "sdcard_ramdump_backup" > /dev/kmsg
		dumpdate=`date +%Y-%m-%d-%H-%M`
		dumpdate="$i-$dumpdate"
#		mv /storage/$folder_name/$i /storage/$folder_name/sdramdump_$dumpdate-$boot_count
		mv /mnt/media_rw/$folder_name/$i /mnt/media_rw/$folder_name/sdramdump_$dumpdate-$boot_count
	    fi
	done
	;;
    "0")
	;;
esac
