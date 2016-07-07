#
# Copyright (C) 2014 MediaTek Inc.
# Modification based on code covered by the mentioned copyright
# and/or permission notice(s).
#

MEDIATEK_RECOVERY_PATH := vendor/mediatek/proprietary/bootable/recovery

LOCAL_SRC_FILES += \
         mt_install.c

ifeq ($(MTK_CACHE_MERGE_SUPPORT), true)
LOCAL_CFLAGS += -DCACHE_MERGE_SUPPORT
endif

ifeq ($(TARGET_USERIMAGES_USE_UBIFS),true)
LOCAL_CFLAGS += -DUBIFS_SUPPORT
LOCAL_STATIC_LIBRARIES += ubiutils
endif

ifeq ($(TARGET_ARCH),arm)
ifeq ($(strip $(MTK_FW_UPGRADE)), yes)
LOCAL_CFLAGS += -DMTK_SYS_FW_UPGRADE
LOCAL_STATIC_LIBRARIES += libfwupgrade
endif
endif

LOCAL_C_INCLUDES += $(MEDIATEK_RECOVERY_PATH) $(MEDIATEK_RECOVERY_PATH)/utils/include

LOCAL_STATIC_LIBRARIES += libpartition


LOCAL_STATIC_LIBRARIES += libapplysig

