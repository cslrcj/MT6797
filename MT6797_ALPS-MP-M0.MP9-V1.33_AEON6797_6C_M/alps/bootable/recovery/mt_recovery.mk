#
# Copyright (C) 2014 MediaTek Inc.
# Modification based on code covered by the mentioned copyright
# and/or permission notice(s).
#

MEDIATEK_RECOVERY_PATH := vendor/mediatek/proprietary/bootable/recovery

LOCAL_SRC_FILES += \
    mt_roots.cpp \
    mt_roots_ubi.cpp \
    mt_recovery.cpp \
    mt_bootloader.cpp \
    mt_install.cpp \
    ../../$(MEDIATEK_RECOVERY_PATH)/utils/mt_check_partition.cpp \
    ../../$(MEDIATEK_RECOVERY_PATH)/utils/mt_common_tk.cpp \
    ../../$(MEDIATEK_RECOVERY_PATH)/utils/mt_sepol.cpp

ifeq ($(WITH_ROOT_CHECK),true)
LOCAL_SRC_FILES += \
    root_check.cpp \
    md5.c \
    cr32.c
endif

ifeq ($(WITH_FOTA),true)
ifeq ($(WITH_GPT_SCHEME), true)
LOCAL_SRC_FILES += \
    ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota_upg.cpp \
    ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota_fs.cpp \
    ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota_common.cpp
else
LOCAL_SRC_FILES += \
    ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota.cpp \
    ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota_fs.cpp \
    ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota_common.cpp \
    ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota_dev.cpp
endif
endif

ifeq ($(WITH_BACKUP_RESTORE),true)
LOCAL_CFLAGS += -DSUPPORT_DATA_BACKUP_RESTORE
endif

ifeq ($(SPECIAL_FACTORY_RESET),true)
LOCAL_CFLAGS += -DSPECIAL_FACTORY_RESET
endif

ifeq ($(WITH_ROOT_CHECK),true)
LOCAL_CFLAGS += -DROOT_CHECK
endif

ifeq ($(WITH_FOTA),true)
LOCAL_CFLAGS += -DSUPPORT_FOTA -DFOTA_SELF_UPGRADE -DFOTA_PHONE_UPGRADE -DFOTA_UI_MESSAGE
LOCAL_CFLAGS += -fno-short-enums
#LOCAL_CFLAGS += -DVERIFY_BOOT_SOURCE -DVERIFY_BOOT_TARGET
#LOCAL_CFLAGS += -DVERIFY_SYSTEM_SOURCE -DVERIFY_SYSTEM_TARGET
#LOCAL_CFLAGS += -DVERIFY_RECOVERY_SOURCE -DVERIFY_RECOVERY_TARGET
#LOCAL_CFLAGS += -DVERIFY_CUSTOM_SOURCE -DVERIFY_CUSTOM_TARGET
endif

ifeq ($(WITH_FOTA),true)
LOCAL_CFLAGS += -DFOTA_FIRST
endif

ifeq ($(MTK_SHARED_SDCARD),yes)
LOCAL_CFLAGS += -DMTK_SHARED_SDCARD
LOCAL_CFLAGS += -DSHARED_SDCARD
endif

ifeq ($(MTK_2SDCARD_SWAP),yes)
LOCAL_CFLAGS += -DMTK_2SDCARD_SWAP
endif

ifeq ($(CACHE_MERGE_SUPPORT),true)
LOCAL_CFLAGS += -DCACHE_MERGE_SUPPORT
endif

ifeq ($(MTK_GMO_ROM_OPTIMIZE),true)
LOCAL_CFLAGS += -DMTK_GMO_ROM_OPTIMIZE
endif


ifeq ($(TARGET_ARCH),arm)
ifeq ($(strip $(MTK_FW_UPGRADE)), yes)
LOCAL_CFLAGS += -DMTK_SYS_FW_UPGRADE
LOCAL_STATIC_LIBRARIES += libfwupgrade
endif
endif

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
LOCAL_CFLAGS += -DUBIFS_SUPPORT
LOCAL_STATIC_LIBRARIES += ubi_ota_update
endif

ifeq ($(PURE_AP_USE_EXTERNAL_MODEM),yes)
LOCAL_CFLAGS += -DEXTERNAL_MODEM_UPDATE
endif

#add for fat merge
ifeq ($(MTK_MLC_NAND_SUPPORT),yes)
LOCAL_CFLAGS += -DBOARD_UBIFS_FAT_MERGE_VOLUME_SIZE=$(BOARD_UBIFS_FAT_MERGE_VOLUME_SIZE)
LOCAL_CFLAGS += -DBOARD_UBIFS_IPOH_VOLUME_SIZE=$(BOARD_UBIFS_IPOH_VOLUME_SIZE)
endif

ifeq ($(WITH_BACKUP_RESTORE),true)
LOCAL_STATIC_LIBRARIES += libbackup_restore libcrypto_static libselinux libsepol
LOCAL_C_INCLUDES += external/libselinux/include
endif


ifeq ($(WITH_FOTA),true)
ifeq ($(TARGET_ARCH),arm64)
LOCAL_STATIC_LIBRARIES += upi_v9_64
else
LOCAL_STATIC_LIBRARIES += upi_v9
endif
endif

LOCAL_C_INCLUDES += kernel \
        $(MEDIATEK_RECOVERY_PATH) \
        $(MEDIATEK_RECOVERY_PATH)/fota/include \
        $(MEDIATEK_RECOVERY_PATH)/utils/include \
        external/libselinux/include \
        external/selinux/libsepol/include \
        system/core/fs_mgr/include \
        bionic/libc
