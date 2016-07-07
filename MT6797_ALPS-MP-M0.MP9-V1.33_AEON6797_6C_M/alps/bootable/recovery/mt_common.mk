#
# Copyright (C) 2014 MediaTek Inc.
# Modification based on code covered by the mentioned copyright
# and/or permission notice(s).
#
MEDIATEK_RECOVERY_PATH := vendor/mediatek/proprietary/bootable/recovery

ifeq ($(TARGET_ARCH), $(filter $(TARGET_ARCH), arm arm64))
    ifneq ($(MTK_BSP_PACKAGE),yes)
        WITH_BACKUP_RESTORE := true
	# SPECIAL_FACTORY_RESET will backup /data/app when do factory reset if SD is existed
	ifeq ($(MTK_SPECIAL_FACTORY_RESET),yes)
	    SPECIAL_FACTORY_RESET := true
        else
            SPECIAL_FACTORY_RESET := false
        endif
    else
        WITH_BACKUP_RESTORE := false
        SPECIAL_FACTORY_RESET := false
    endif
else
    WITH_BACKUP_RESTORE := false
endif

##########################################
# Feature option
##########################################

ifeq ($(MTK_GPT_SCHEME_SUPPORT), yes)
    WITH_GPT_SCHEME := true
else
    WITH_GPT_SCHEME := false
endif

ifdef MTK_FOTA_SUPPORT
    ifeq ($(MTK_FOTA_SUPPORT),yes)
        WITH_FOTA := true
    else
        WITH_FOTA := false
    endif
else
    WITH_FOTA := false
endif

ifeq ($(MTK_CACHE_MERGE_SUPPORT),yes)
    CACHE_MERGE_SUPPORT := true
else
    CACHE_MERGE_SUPPORT := false
endif

ifeq ($(TARGET_ARCH), $(filter $(TARGET_ARCH), arm arm64))
    ifneq ($(MTK_BSP_PACKAGE),yes)
        WITH_ROOT_CHECK := true
    else
        WITH_ROOT_CHECK := false
    endif
endif


##########################################
# Static library - UBIFS_SUPPORT
##########################################

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
include $(CLEAR_VARS)
LOCAL_SRC_FILES := roots.cpp \
                   mt_roots.cpp \
                   mt_roots_ubi.cpp

LOCAL_MODULE := ubiutils

LOCAL_C_INCLUDES += system/extras/ext4_utils \
                    $(MEDIATEK_RECOVERY_PATH) \
                    system/core/fs_mgr/include \
                    $(MEDIATEK_RECOVERY_PATH)/utils/include

LOCAL_STATIC_LIBRARIES += libz ubi_ota_update

LOCAL_CFLAGS += -DUBIFS_SUPPORT

#add for fat merge
ifeq ($(MTK_MLC_NAND_SUPPORT),yes)
LOCAL_CFLAGS += -DBOARD_UBIFS_FAT_MERGE_VOLUME_SIZE=$(BOARD_UBIFS_FAT_MERGE_VOLUME_SIZE)
LOCAL_CFLAGS += -DBOARD_UBIFS_IPOH_VOLUME_SIZE=$(BOARD_UBIFS_IPOH_VOLUME_SIZE)
endif

LOCAL_MODULE_TAGS := eng

include $(BUILD_STATIC_LIBRARY)
endif

##########################################
# Static library - WITH_FOTA
##########################################

ifeq ($(WITH_FOTA),true)
include $(CLEAR_VARS)
ifeq ($(TARGET_ARCH),arm64)
LOCAL_PREBUILT_LIBS := ../../$(MEDIATEK_RECOVERY_PATH)/fota/upi_v9_64.a
else
LOCAL_PREBUILT_LIBS := ../../$(MEDIATEK_RECOVERY_PATH)/fota/upi_v9.a
endif
include $(BUILD_MULTI_PREBUILT)
endif

#############################################################################
ifeq ($(WITH_FOTA),true)
include $(CLEAR_VARS)
ifeq ($(TARGET_USERIMAGES_USE_EXT4), true)
    LOCAL_CFLAGS += -DUSE_EXT4
endif
LOCAL_C_INCLUDES:= system/extras/ext4_utils \
                   kernel \
                   $(LOCAL_CUST_INC_PATH) \
                   $(MEDIATEK_RECOVERY_PATH) \
                   $(MEDIATEK_RECOVERY_PATH)/fota/include \
                   $(MEDIATEK_RECOVERY_PATH)/fota \
                   $(LOCAL_PATH)/fota/include \
                   $(LOCAL_PATH)/fota \
                   system/vold \
                   external/openssl/include \
                   system/core/fs_mgr/include \
                   $(MEDIATEK_RECOVERY_PATH)/utils/include

LOCAL_SRC_FILES := ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota_main.cpp \
                   ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota_common.cpp \
                   ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota_fs.cpp \
                   bootloader.cpp \
                   mt_bootloader.cpp \
                   roots.cpp \
                   mt_roots.cpp

ifeq ($(WITH_GPT_SCHEME), true)
LOCAL_SRC_FILES += ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota_upg.cpp
else
LOCAL_SRC_FILES += ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota_dev.cpp
LOCAL_SRC_FILES += ../../$(MEDIATEK_RECOVERY_PATH)/fota/fota.cpp
endif

#LOCAL_CFLAGS += -fshort-enums -g
LOCAL_CFLAGS += -fno-short-enums
LOCAL_CFLAGS += -DSUPPORT_FOTA -DFOTA_SELF_UPGRADE
#LOCAL_CFLAGS += -DVERIFY_BOOT_SOURCE -DVERIFY_BOOT_TARGET
#LOCAL_CFLAGS += -DVERIFY_SYSTEM_SOURCE -DVERIFY_SYSTEM_TARGET
#LOCAL_CFLAGS += -DVERIFY_RECOVERY_SOURCE -DVERIFY_RECOVERY_TARGET
#LOCAL_CFLAGS += -DVERIFY_CUSTOM_SOURCE -DVERIFY_CUSTOM_TARGET
LOCAL_MODULE := fota1
LOCAL_MODULE_TAGS := optional
LOCAL_STATIC_LIBRARIES :=  libext4_utils_static \
                           libmincrypt \
                           libmtdutils \
                           libfs_mgr libcutils \
                           libpartition

ifeq ($(TARGET_ARCH),arm64)
LOCAL_STATIC_LIBRARIES += upi_v9_64
else
LOCAL_STATIC_LIBRARIES += upi_v9
endif

include $(BUILD_EXECUTABLE)
endif

#############################################################################

ifeq ($(TARGET_ARCH),arm)
ifeq ($(strip $(MTK_FW_UPGRADE)), yes)
include $(CLEAR_VARS)
LOCAL_PREBUILT_LIBS += libfwupgrade.a
include $(BUILD_MULTI_PREBUILT)
endif
endif

include $(CLEAR_VARS)
LOCAL_C_INCLUDES += \
    $(MEDIATEK_RECOVERY_PATH)/utils/include \
    bionic/libc

LOCAL_SRC_FILES := \
    ../../$(MEDIATEK_RECOVERY_PATH)/utils/mt_gpt.cpp \
    ../../$(MEDIATEK_RECOVERY_PATH)/utils/mt_pmt.cpp \
    ../../$(MEDIATEK_RECOVERY_PATH)/utils/mt_partition.cpp

LOCAL_MODULE := libpartition
include $(BUILD_STATIC_LIBRARY)
