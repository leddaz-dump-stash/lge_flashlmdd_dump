#!/system/bin/sh

memory_log_prop=`getprop persist.product.lge.service.memory.enable`

touch /data/logger/memory.log
chmod 0644 /data/logger/memory.log


storage_low_prop=`getprop persist.product.lge.service.logger.low`

optionR="-r8192"

if [ "$storage_low_prop" = "1" ]; then
    optionR="-r1024"
fi


case "$memory_log_prop" in
    #6)
    #    /system_ext/bin/memory_logger -f /data/logger/memory.log -n 4 -r 1024 -t 300
    #;;
    5)
        /system_ext/bin/memory_logger -f /data/logger/memory.log -n 99 -r 8192 -t 90
    ;;
    4)
        /system_ext/bin/memory_logger -f /data/logger/memory.log -n 79 -r 8192 -t 90
    ;;
    3)
        /system_ext/bin/memory_logger -f /data/logger/memory.log -n 59 $optionR -t 90
    ;;
    2)
        /system_ext/bin/memory_logger -f /data/logger/memory.log -n 39 -r 8192 -t 90
    ;;
    1)
        /system_ext/bin/memory_logger -f /data/logger/memory.log -n 29 -r 8192 -t 90
    ;;
esac
