/*
 * Copyright (C) 2015 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "device.h"

static const char* MENU_ITEMS[] = {
    "Reboot system now",
    "Reboot to bootloader",
    "Apply update from ADB",
    "Apply update from SD card",
#if defined(SUPPORT_SDCARD2) && !defined(MTK_SHARED_SDCARD) //wschen 2012-11-15
    "Apply update from sdcard2",
#endif //SUPPORT_SDCARD2
    "Wipe data/factory reset",
    "Wipe cache partition",
#ifdef SUPPORT_DATA_BACKUP_RESTORE //wschen 2011-03-09
    "Backup user data",
    "Restore user data",
#endif
#ifdef ROOT_CHECK
    "Root integrity check",
#endif
    "Mount /system",
    "View recovery logs",
    "Power off",
    NULL
};

static const char* FORCE_ITEMS[] =  {"Reboot system now",
                                     "Apply sdcard:update.zip",
#if defined(SUPPORT_SDCARD2) && !defined(MTK_SHARED_SDCARD) //wschen 2012-11-15
                                     "Apply sdcard2:update.zip",
#endif //SUPPORT_SDCARD2
                                     NULL };

const char* const* Device::GetForceMenuItems() {
  return FORCE_ITEMS;
}

const char* const* Device::GetMenuItems() {
  return MENU_ITEMS;
}


Device::BuiltinAction Device::InvokeMenuItem(int menu_position) {
        switch (menu_position) {
#if defined(SUPPORT_SDCARD2) && !defined(MTK_SHARED_SDCARD) //wschen 2012-11-15
          case 0: return REBOOT;
          case 1: return REBOOT_BOOTLOADER;
          case 2: return APPLY_ADB_SIDELOAD;
          case 3: return APPLY_EXT;
          case 4: return APPLY_SDCARD2;
          case 5: return WIPE_DATA;
          case 6: return WIPE_CACHE;
#ifdef SUPPORT_DATA_BACKUP_RESTORE
          case 7: return USER_DATA_BACKUP;
          case 8: return USER_DATA_RESTORE;
#ifdef ROOT_CHECK
          case 9: return CHECK_ROOT;
          case 10: return MOUNT_SYSTEM;
          case 11: return READ_RECOVERY_LASTLOG;
          case 12: return SHUTDOWN;
#else
          case 9: return MOUNT_SYSTEM;
          case 10: return READ_RECOVERY_LASTLOG;
          case 11: return SHUTDOWN;
#endif
#else
#ifdef ROOT_CHECK
          case 7: return CHECK_ROOT;
          case 8: return MOUNT_SYSTEM;
          case 9: return READ_RECOVERY_LASTLOG;
          case 10: return SHUTDOWN;
#else
          case 7: return MOUNT_SYSTEM;
          case 8: return READ_RECOVERY_LASTLOG;
          case 9: return SHUTDOWN;
#endif
#endif
          default: return NO_ACTION;
#else
          case 0: return REBOOT;
          case 1: return REBOOT_BOOTLOADER;
          case 2: return APPLY_ADB_SIDELOAD;
          case 3: return APPLY_EXT;
          case 4: return WIPE_DATA;
          case 5: return WIPE_CACHE;
#ifdef SUPPORT_DATA_BACKUP_RESTORE
          case 6: return USER_DATA_BACKUP;
          case 7: return USER_DATA_RESTORE;
#ifdef ROOT_CHECK
          case 8: return CHECK_ROOT;
          case 9: return MOUNT_SYSTEM;
          case 10: return READ_RECOVERY_LASTLOG;
          case 11: return SHUTDOWN;
#else
          case 8: return MOUNT_SYSTEM;
          case 9: return READ_RECOVERY_LASTLOG;
          case 10: return SHUTDOWN;
#endif
#else
#ifdef ROOT_CHECK
          case 6: return CHECK_ROOT;
          case 7: return MOUNT_SYSTEM;
          case 8: return READ_RECOVERY_LASTLOG;
          case 9: return SHUTDOWN;
#else
          case 6: return MOUNT_SYSTEM;
          case 7: return READ_RECOVERY_LASTLOG;
          case 8: return SHUTDOWN;
#endif
#endif
          default: return NO_ACTION;
#endif //SUPPORT_SDCARD2
        }
}

Device::BuiltinAction Device::InvokeForceMenuItem(int menu_position) {
        switch (menu_position) {
          case 0: return REBOOT;
          case 1: return FORCE_APPLY_SDCARD_SIDELOAD;
#if defined(SUPPORT_SDCARD2) && !defined(MTK_SHARED_SDCARD) //wschen 2012-11-15
          case 2: return FORCE_APPLY_SDCARD2_SIDELOAD;
#endif //SUPPORT_SDCARD2
          default: return NO_ACTION;
        }
}

int Device::HandleMenuKey(int key, int visible) {
  if (!visible) {
    return kNoAction;
  }

  switch (key) {
    case KEY_DOWN:
    case KEY_VOLUMEDOWN:
      return kHighlightDown;

    case KEY_UP:
    case KEY_VOLUMEUP:
      return kHighlightUp;

    case KEY_ENTER:
    case KEY_POWER:
      return kInvokeItem;

    default:
      // If you have all of the above buttons, any other buttons
      // are ignored. Otherwise, any button cycles the highlight.
      return ui_->HasThreeButtons() ? kNoAction : kHighlightDown;
  }
}
