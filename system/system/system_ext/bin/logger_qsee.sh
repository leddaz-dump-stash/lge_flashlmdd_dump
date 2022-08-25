#!/system/bin/sh
source check_data_mount.sh
log_to_data_partition=`is_ext4_f2fs_data_partition`
log_file="qsee.log.0"

ro_build_ab_update=`getprop ro.build.ab_update`
if [ "$ro_build_ab_update" = "true" ]; then
tmp_log_path="mnt/product/els"
else
tmp_log_path="cache"
fi

#8mb
log_size=8388608
total_logger_count=6
if [[ $log_to_data_partition == 1 ]]; then
    log_path="/data/logger"
else
    log_path=/${tmp_log_path}/encryption_log
fi

if ! [ -f "${log_path}/qsee.log.0" ]; then
    current_logger_count=1
else
    current_logger_count=`ls -lq ${log_path}/qsee.log* | wc -l`
fi

rotate_log() {
    log_path=$1
    for count in $(seq $(($current_logger_count-1)) -1 0);
        do mv ${log_path}/"qsee.log."$count ${log_path}/"qsee.log."$(($count+1));
    done
}

dump_tzlog() {
    file_name=$1/"qsee.log.0"
    copy_size=$log_size
    touch $file_name
    chmod 0644 $file_name

    file_size=`wc -c $file_name | tr -s '\t' ' ' | cut -d' ' -f1`
    if [ $file_size -gt $log_size-1 ];then
        if [ $current_logger_count -gt $total_logger_count-1 ]; then
            current_logger_count=$total_logger_count
        else
            current_logger_count=`expr $current_logger_count + 1`
        fi
    fi
    if [ $file_size -gt $log_size-1 ];then
        rotate_log $1
    else
        copy_size=`expr $log_size - $file_size`
    fi

    if [[ $log_to_data_partition == 1 ]]; then
        dd if=/d/tzdbg/qsee_log bs=1 count=$copy_size >> $file_name
    else
        for i in {0..1024..1}
        do
            dd if=/d/tzdbg/qsee_log bs=1 count=4096 >> $file_name
            log_to_data_partition=`is_ext4_f2fs_data_partition`
            if [[ $log_to_data_partition == 1 ]]; then
                break;
            fi
        done
    fi
}

wait_file_ready() {
    S_DIR="/d/tzdbg/qsee_log"
    while [ `stat ${S_DIR} 2>/dev/null 1>&2; echo $?` -ne 0 ]
    do
        boot_complete=`getprop sys.boot_completed`
        if [[ $boot_complete == 1 ]]; then
            exit 1
        else
            sleep 1
        fi
    done
}

wait_file_ready
while true
do
    if [[ $log_to_data_partition == 1 ]]; then
        move_log "/data/logger/${log_file}" "/${tmp_log_path}/encryption_log/${log_file}"
        while true; do
            dump_tzlog /data/logger
        done
    else
        while true; do
            dump_tzlog /${tmp_log_path}/encryption_log
            log_to_data_partition=`is_ext4_f2fs_data_partition`
            if [[ $log_to_data_partition == 1 ]]; then
                break;
            fi
        done
    fi
done
