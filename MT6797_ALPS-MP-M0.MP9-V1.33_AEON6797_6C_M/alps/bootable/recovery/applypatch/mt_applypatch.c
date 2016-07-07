/*
* Copyright (C) 2014 MediaTek Inc.
* Modification based on code covered by the mentioned copyright
* and/or permission notice(s).
*/

#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include "applypatch.h"
#include "mt_applypatch.h"

//TEE update related
int LoadTeeContents(const char* filename, FileContents* file) {
    file->data = NULL;

    if (stat(filename, &file->st) != 0) {
        printf("failed to stat \"%s\": %s\n", filename, strerror(errno));
        return -1;
    }

    file->size = file->st.st_size;
    file->data = malloc(file->size);

    FILE* f = fopen(filename, "rb");
    if (f == NULL) {
        printf("failed to open \"%s\": %s\n", filename, strerror(errno));
        free(file->data);
        file->data = NULL;
        return -1;
    }

    ssize_t bytes_read = fread(file->data, 1, file->size, f);
    if (bytes_read != file->size) {
        printf("short read of \"%s\" (%ld bytes of %ld)\n",
               filename, (long)bytes_read, (long)file->size);
        free(file->data);
        file->data = NULL;
        fclose(f);
        return -1;
    }
    fclose(f);

    return 0;
}

int TeeUpdate(const char* tee_image, const char* target_filename) {

    FileContents source_file;
    source_file.data = NULL;

    if (LoadTeeContents(tee_image, &source_file) == 0) {
        if (WriteToPartition(source_file.data, source_file.size, target_filename) != 0) {
            printf("write of patched data to %s failed\n", target_filename);
            free(source_file.data);
            return 1;
        }
    }

    free(source_file.data);
    // Success!
    return 0;
}
