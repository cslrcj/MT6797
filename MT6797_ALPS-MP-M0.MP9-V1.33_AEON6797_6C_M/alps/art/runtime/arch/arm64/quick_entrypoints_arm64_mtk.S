/*
 * Copyright (C) 2014 The Android Open Source Project
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

#include "asm_support_arm64.S"

#include "arch/quick_alloc_entrypoints.S"

// Macro to facilitate adding new entrypoints which call to native function directly.
// Currently, xSELF is the only thing we need to take care of between managed code and AAPCS.
// But we might introduce more differences.
.macro NATIVE_DOWNCALL name, entrypoint
    .extern \entrypoint
ENTRY \name
    stp    xSELF, xLR, [sp, #-16]!
    bl     \entrypoint
    ldp    xSELF, xLR, [sp], #16
    ret
END \name
.endm

NATIVE_DOWNCALL art_quick_powf powf
NATIVE_DOWNCALL art_quick_pow pow
