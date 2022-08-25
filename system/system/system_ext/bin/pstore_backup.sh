#!/system/bin/sh

max_count=10
backup_folder=/data/ramoops
logger_folder=/data/logger
result_file=$backup_folder/pstore_backup_result
crash_result_file=$backup_folder/pstore_backup_crash
count_file=$backup_folder/pstore_next_count
crash_count_file=$backup_folder/pstore_crash_count
boot_count_file=$backup_folder/boot_next_count
ftm_result_file=$backup_folder/ftm_crash_result
pstore_part=/dev/block/bootdevice/by-name/pstore
ftm_part=/dev/block/bootdevice/by-name/ftm

do_copy=0
copy_ramoops()
{
	cp -fa $backup_folder/pstore* $logger_folder/
	cp -fa $backup_folder/kernel_pstore* $logger_folder/
	cp -fa $backup_folder/cmdline* $logger_folder/
	cp -fa $backup_folder/kernel_cmdline* $logger_folder/
#	cp -fa $backup_folder/ftm* $logger_folder/
	strings $backup_folder/ftm_crash > $logger_folder/ftm_crash
	strings $backup_folder/kernel_ftm_crash > $logger_folder/kernel_ftm_crash
	chmod -h 664 $logger_folder/ftm_crash
	chmod -h 664 $logger_folder/kernel_ftm_crash
	cp -fa $backup_folder/boot* $logger_folder/
	cp -fa $backup_folder/kernel_boot* $logger_folder/
}

function is_ext4_f2fs_data_partition {
	local ret=0
	proc_mounts="/proc/mounts"

	while read -r line
	do
		mount_info=($line)
		mount_path=${mount_info[1]}
		mount_fs=${mount_info[2]}

		if [[ $mount_path == "/data" ]]; then
			if [[ $mount_fs == "ext4" ]] || [[ $mount_fs == "f2fs" ]]; then
				ret=1
				break
			fi
		fi
	done < "$proc_mounts"
	echo $ret
}

data_partition=`is_ext4_f2fs_data_partition`

if [ $data_partition -eq 0 ]; then
	exit 1
fi

if [ $# -eq 1 ] ; then
    uptimecmd=`uptime -p`
	if [ -f $boot_count_file ] ; then
		count=`cat $boot_count_file`
		if (($count>$max_count)) ; then
			exit 1
		fi
	else
	    exit 1
	fi

	if [ $count -eq 0 ] ; then
	    count=$(($max_count-1))
	else
	    count=$(($count-1))
	fi

	echo "user_reboot_reason=$1" >> $backup_folder/cmdline$count
	echo "uptime=$uptimecmd" >> $backup_folder/cmdline$count
	echo "user_reboot_reason=$1" >> $backup_folder/kernel_cmdline$count
	echo "uptime=$uptimecmd" >> $backup_folder/kernel_cmdline$count

	cat $backup_folder/cmdline$count | tr "\n" " " > $backup_folder/tmpcmdline$count
	mv -f $backup_folder/tmpcmdline$count $backup_folder/cmdline$count
	chmod -h 664 $backup_folder/cmdline$count

	cat $backup_folder/kernel_cmdline$count | tr "\n" " " > $backup_folder/tmpkernel_cmdline$count
	mv -f $backup_folder/tmpkernel_cmdline$count $backup_folder/kernel_cmdline$count
	chmod -h 664 $backup_folder/kernel_cmdline$count

	cp -fa $backup_folder/cmdline$count $logger_folder/
	cp -fa $backup_folder/kernel_cmdline$count $logger_folder/
	exit 0
fi

# cmdline & boot_log start
if [ -f $boot_count_file ] ; then
	count=`cat $boot_count_file`
	case $count in
		"" ) count=0
	esac
else
	count=0
fi

count_new=$(($count+1))
if (($count_new>=$max_count)) ; then
	count_new=0
fi
echo $count_new > $boot_count_file
chmod -h 664 $boot_count_file

cat /proc/cmdline > $backup_folder/cmdline$count
chmod -h 664 $backup_folder/cmdline$count

cat /proc/cmdline > $backup_folder/kernel_cmdline$count
chmod -h 664 $backup_folder/kernel_cmdline$count

dmesg > $backup_folder/boot_log$count
chmod -h 664 $backup_folder/boot_log$count

dmesg > $backup_folder/kernel_boot_log$count
chmod -h 664 $backup_folder/kernel_boot_log$count

echo [[[[ Written $backup_folder/boot_log$count $max_count ]]]]
echo [[[[ Written $backup_folder/kernel_boot_log$count $max_count ]]]]

do_copy=1
# cmdline & boot_log done


rm -f $result_file
rm -f $crash_result_file
rm -r $ftm_result_file
/system_ext/bin/pstore_backup $pstore_part
/system_ext/bin/ftm_backup $ftm_part

if [ -f $result_file ] ; then
	if [ -f $count_file ] ; then
		count=`cat $count_file`
		case $count in
			"" ) count=0
		esac
	else
		count=0
	fi
	echo [[[[ Written $backup_folder/pstore_backup$count $max_count ]]]]
	mv $result_file $backup_folder/pstore_backup$count
	echo -e "\n" >> $backup_folder/pstore_backup$count
	cat /proc/cmdline >> $backup_folder/pstore_backup$count
	# reason is att permission certification
	chmod -h 664 $backup_folder/pstore_backup$count

	echo [[[[ Written $backup_folder/kernel_pstore_backup$count $max_count ]]]]
	cp -fa $backup_folder/pstore_backup$count $backup_folder/kernel_pstore_backup$count
	# reason is att permission certification
	chmod -h 664 $backup_folder/kernel_pstore_backup$count

	count=$(($count+1))
	if (($count>=$max_count)) ; then
		count=0
	fi
	echo $count > $count_file
	chmod -h 664 $count_file
	do_copy=1
fi

if [ -f $crash_result_file ] ; then
	if [ -f $crash_count_file ] ; then
		count=`cat $crash_count_file`
		case $count in
			"" ) count=0
		esac
	else
		count=0
	fi
	echo [[[[ Written $backup_folder/pstore_crash$count $max_count ]]]]
	mv $crash_result_file $backup_folder/pstore_crash$count
	echo -e "\n" >> $backup_folder/pstore_crash$count
	cat /proc/cmdline >> $backup_folder/pstore_crash$count
	# reason is att permission certification
	chmod -h 664 $backup_folder/pstore_crash$count

	echo [[[[ Written $backup_folder/kernel_pstore_crash$count $max_count ]]]]
	cp -fa $backup_folder/pstore_crash$count $backup_folder/kernel_pstore_crash$count
	# reason is att permission certification
	chmod -h 664 $backup_folder/kernel_pstore_crash$count

	count=$(($count+1))
	if (($count>=$max_count)) ; then
		count=0
	fi
	echo $count > $crash_count_file
	chmod -h 664 $crash_count_file
	do_copy=1
fi

if [ -f $ftm_result_file ] ; then
	mv $ftm_result_file $backup_folder/ftm_crash
	# reason is att permission certification
	chmod -h 664 $backup_folder/ftm_crash

	cp -fa $backup_folder/ftm_crash $backup_folder/kernel_ftm_crash
	# reason is att permission certification
	chmod -h 664 $backup_folder/kernel_ftm_crash
	    do_copy=1
fi

if [ do_copy -eq 1 ] ; then
	copy_ramoops
fi
