#!/system/bin/sh
echo 1 > /sys/kernel/tracing/instances/dfc/tracing_on
echo '' > /sys/kernel/tracing/instances/dfc/trace
echo '' > /sys/kernel/tracing/instances/dfc/set_event
echo 1 > /sys/kernel/tracing/instances/dfc/events/dfc/enable
echo 1 > /sys/kernel/tracing/instances/dfc/events/wda/enable
echo 1 > /sys/kernel/tracing/instances/dfc/events/net/net_dev_xmit/enable
echo 1 > /sys/kernel/tracing/instances/dfc/events/net/net_dev_start_xmit/enable
echo 1 > /sys/kernel/tracing/instances/dfc/events/net/net_dev_queue/enable
echo 1 > /sys/kernel/tracing/instances/dfc/tracing_on

source check_data_mount.sh
log_to_data_partition=`is_ext4_f2fs_data_partition`
log_file="dfc.log"

bootmode_charger=`is_bootmode_charger`

bootmode_prop=`getprop ro.bootmode`
crypto_type_prop=`getprop ro.crypto.type`

ro_build_ab_update=`getprop ro.build.ab_update`
if [ "$ro_build_ab_update" = "true" ]; then
tmp_log_path="mnt/product/els"
else
tmp_log_path="cache"
fi

touch /data/logger/${log_file}
chmod 644 /data/logger/${log_file}

if [[ $log_to_data_partition == 1 ]]; then
    move_log "/data/logger/${log_file}" "/${tmp_log_path}/encryption_log/${log_file}.4"
    move_log "/data/logger/${log_file}" "/${tmp_log_path}/encryption_log/${log_file}.3"
    move_log "/data/logger/${log_file}" "/${tmp_log_path}/encryption_log/${log_file}.2"
    move_log "/data/logger/${log_file}" "/${tmp_log_path}/encryption_log/${log_file}.1"
    move_log "/data/logger/${log_file}" "/${tmp_log_path}/encryption_log/${log_file}"

    /system_ext/bin/dfc_logger -f /data/logger/dfc.log -s 8388608 -m 10
else
    touch /${tmp_log_path}/encryption_log/${log_file}
    chmod 0644 /${tmp_log_path}/encryption_log/${log_file}

    # tmp_log_path is small sized partition, so limit file_size and file_cnt for long-term testing
    if [[ $bootmode_charger == 1 ]]; then
        file_size=2097152
        file_cnt=5
    fi

    /system_ext/bin/dfc_logger -f /${tmp_log_path}/encryption_log/${log_file} -s $file_size -m $file_cnt
fi
rm -rf /${tmp_log_path}/encryption_log/${log_file}*
