/*
* Copyright (C) 2014 MediaTek Inc.
* Modification based on code covered by the mentioned copyright
* and/or permission notice(s).
*/

#include <fs_mgr.h>
#include <fcntl.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>
#include "common.h"
#include "roots.h"
#include "bootloader.h"
#include "mt_partition.h"

#ifdef __cplusplus
extern "C" {
#endif

int get_nand_type(void)
{
    Volume *v = volume_for_path("/misc");
    if (v == NULL) {
      LOGE("Cannot load volume /misc!\n");
      return -1;
    }
    if (strcmp(v->fs_type, "emmc") == 0)
    {
        printf("nand type is emmc\n");
        return 1;
    }
    printf("nand type is mlc\n");
    return 0;
}

int get_phone_encrypt_state(struct phone_encrypt_state *out) {

    Volume *v = volume_for_path("/misc");

    if (v == NULL) {
      LOGE("Cannot load volume /misc!\n");
      return -1;
    }

    if (strcmp(v->fs_type, "emmc") == 0) {
        int dev = -1;
        struct phone_encrypt_state temp;
        int count;

        dev = open(v->blk_device, O_RDONLY);
        if (dev < 0)  {
            LOGE("Can't open%s\n(%s)\n", v->blk_device, strerror(errno));
            return -1;
        }

        if (lseek(dev, PHONE_ENCRYPT_OFFSET, SEEK_SET) == -1) {
            LOGE("Failed seeking %s\n(%s)\n", v->blk_device, strerror(errno));
            close(dev);
            return -1;
        }

        count = read(dev, &temp, sizeof(temp));

        if (count != sizeof(temp)) {
            LOGE("Failed reading %s\n(%s)\n", v->blk_device, strerror(errno));
            close(dev);
            return -1;
        }

        if (close(dev) != 0) {
            LOGE("Failed closing %s\n(%s)\n", v->blk_device, strerror(errno));
            return -1;
        }

        memcpy(out, &temp, sizeof(temp));
        return 0;

    } else {
        out->state = 0;
        return 0;
    }
}


int set_phone_encrypt_state(const struct phone_encrypt_state *in) {

    Volume *v = volume_for_path("/misc");
    if (v == NULL) {
      LOGE("Cannot load volume /misc!\n");
      return -1;
    }

    if (strcmp(v->fs_type, "emmc") == 0) {
        int dev = -1;
        int count;

        dev = open(v->blk_device, O_WRONLY | O_SYNC);
        if (dev < 0)  {
            LOGE("Can't open %s\n(%s)\n", v->blk_device, strerror(errno));
            return -1;
        }

        if (lseek(dev, PHONE_ENCRYPT_OFFSET, SEEK_SET) == -1) {
            LOGE("Failed seeking %s\n(%s)\n", v->blk_device, strerror(errno));
            close(dev);
            return -1;
        }

        count = write(dev, in, sizeof(*in));
        if (count != sizeof(*in)) {
            LOGE("Failed writing %s\n(%s)\n", v->blk_device, strerror(errno));
            close(dev);
            return -1;
        }
        if (close(dev) != 0) {
            LOGE("Failed closing %s\n(%s)\n", v->blk_device, strerror(errno));
            return -1;
        }
        return 0;

    } else {
        return 0;
    }
}

int set_ota_result(int result) {

    Volume *v = volume_for_path("/misc");
    if (v == NULL) {
      LOGE("Cannot load volume /misc!\n");
      return -1;
    }

    if (strcmp(v->fs_type, "emmc") == 0) {
        int dev = -1;
        int count;

        dev = open(v->blk_device, O_WRONLY | O_SYNC);
        if (dev < 0)  {
            LOGE("Can't open %s\n(%s)\n", v->blk_device, strerror(errno));
            return -1;
        }

        if (lseek(dev, OTA_RESULT_OFFSET, SEEK_SET) == -1) {
            LOGE("Failed seeking %s\n(%s)\n", v->blk_device, strerror(errno));
            close(dev);
            return -1;
        }

        count = write(dev, &result, sizeof(result));
        if (count != sizeof(result)) {
            LOGE("Failed writing %s\n(%s)\n", v->blk_device, strerror(errno));
            close(dev);
            return -1;
        }
        if (close(dev) != 0) {
            LOGE("Failed closing %s\n(%s)\n", v->blk_device, strerror(errno));
            return -1;
        }
        sync();
        return 0;

    } else {
        return 0;
    }

}

/* Write bootloader paramenter block */
int mt_set_bootloader_message(const char *command, const char *status, const char *stage,
    const char *fmt, ...)
{
    int ret;
    int i;
    struct bootloader_message boot;
    va_list vl;

    memset(&boot, 0, sizeof(boot));

    if (command)
        strlcpy(boot.command, command, sizeof(boot.command));
    if (status)
        strlcpy(boot.status, status, sizeof(boot.status));
    if (stage)
        strlcpy(boot.stage, stage, sizeof(boot.stage));
    if (fmt)    {
        va_start(vl, fmt);
        ret = vsprintf(boot.recovery, fmt, vl);
        va_end(vl);
    }

    ret = set_bootloader_message(&boot);
    sync();

    return ret;
}

/* Clear contents in bootloader paramenter block */
int mt_clear_bootloader_message(void)
{
    return mt_set_bootloader_message(NULL, NULL, NULL, NULL);
}

int mt_get_bootloader_message_block(struct bootloader_message *out,
                                        const Volume* v) {
    int dev = -1;

    dev = open(v->blk_device, O_RDONLY);
    if (dev < 0)  {
        LOGE("Can't open %s (%s)\n", v->blk_device, strerror(errno));
        return -1;
    }

    struct bootloader_message temp;
    int count = read(dev, &temp, sizeof(temp));
    if (count != sizeof(temp)) {
        LOGE("Failed reading %s (%s)\n", v->blk_device, strerror(errno));
        close(dev);
        return -1;
    }
    if (close(dev) != 0) {
        LOGE("Failed closing %s (%s)\n", v->blk_device, strerror(errno));
        return -1;
    }
    memcpy(out, &temp, sizeof(temp));
    return 0;
}

int mt_set_bootloader_message_block(const struct bootloader_message *in,
                                        const Volume* v) {
    int dev = -1;

    dev = open(v->blk_device, O_WRONLY | O_SYNC);
    if (dev < 0)  {
        LOGE("Can't open %s (%s)\n", v->blk_device, strerror(errno));
        return -1;
    }
    int count = write(dev, in, sizeof(*in));
    if (count != sizeof(*in)) {
        LOGE("Failed writing %s (%s)\n", v->blk_device, strerror(errno));
        close(dev);
        return -1;
    }
    if (close(dev) != 0) {
        LOGE("Failed closing %s (%s)\n", v->blk_device, strerror(errno));
        return -1;
    }
    return 0;
}

#ifdef __cplusplus
}
#endif

