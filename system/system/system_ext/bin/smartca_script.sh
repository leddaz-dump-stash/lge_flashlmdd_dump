#!/bin/sh

function end_smartca_update {
    /product/bin/laop_cmd setprop persist.vendor.lge.smartca.changed 2
    log -p i -t "${LOG_TAG}" "$@"
    exit 0
}

LOG_TAG="smartca script"
SMARTCA_RES_PATH=/mnt/product/carrier/_SMARTCA_RES
SMARTCA_DATA_RES_PATH=/data/shared/cust
SMARTCA_BOOT_ANI_RES_FILE=${SMARTCA_DATA_RES_PATH}/bootanimation.zip
SMARTCA_BOOT_SOUND_RES_FILE=${SMARTCA_DATA_RES_PATH}/PowerOn.ogg
SMARTCA_BOOT_SOUND_RES_FILE_WAV=${SMARTCA_DATA_RES_PATH}/PowerOn.wav

if [ "$1" == "undo" ]; then
    log -p i -t "${LOG_TAG}" "[SBP] smartca undo start"

    rm -rf ${SMARTCA_RES_PATH:?}
    rm -rf ${SMARTCA_DATA_RES_PATH:?}

    # set 2 to distinguish undo task done
    /product/bin/laop_cmd setprop persist.vendor.lge.smartca.undo 2

    exit 0
fi

if [ [ -d ${SMARTCA_RES_PATH} ] && [ -f ${SMARTCA_BOOT_SOUND_RES_FILE_WAV} ] ]; then
    end_smartca_update "[SBP] ${SMARTCA_RES_PATH} and ${SMARTCA_BOOT_SOUND_RES_FILE_WAV} exists"
fi

if [ ! -f ${SMARTCA_BOOT_ANI_RES_FILE} ]; then
    end_smartca_update "[SBP] ${SMARTCA_BOOT_ANI_RES_FILE} not exists"
fi

log -p i -t "${LOG_TAG}" "[SBP] smartca resource update start"

# prevent copying smartca bootanimation, in ResourcePackageManagmer, when it is running in GQA SingleCA
SINGLECA_SUBMIT=$(/product/bin/laop_cmd getprop ro.vendor.lge.singleca.submit)
if [ "${SINGLECA_SUBMIT}" = "1" ]; then
    end_smartca_update "[SBP] singleca.submit enabled"
fi

chown -R system:system ${SMARTCA_DATA_RES_PATH}
chmod 775 ${SMARTCA_DATA_RES_PATH}
chmod -R 775 ${SMARTCA_DATA_RES_PATH:?}/*

mkdir ${SMARTCA_RES_PATH}
chown -R system:system ${SMARTCA_RES_PATH}
chmod 775 ${SMARTCA_RES_PATH}
chmod -R 775 ${SMARTCA_RES_PATH:?}/*

if [ -f ${SMARTCA_BOOT_ANI_RES_FILE} ]; then
    cp -pf ${SMARTCA_BOOT_ANI_RES_FILE} ${SMARTCA_RES_PATH}
fi

if [ -f ${SMARTCA_BOOT_SOUND_RES_FILE} ]; then
    cp -pf ${SMARTCA_BOOT_SOUND_RES_FILE} ${SMARTCA_RES_PATH}
fi

if [ -f ${SMARTCA_BOOT_SOUND_RES_FILE_WAV} ]; then
    cp -pf ${SMARTCA_BOOT_SOUND_RES_FILE_WAV} ${SMARTCA_RES_PATH}
fi

/product/bin/laop_cmd setprop persist.vendor.lge.smartca.changed 2
