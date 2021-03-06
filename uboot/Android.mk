#
# Copyright (C) 2011 The Android Open-Source Project
# Copyright (C) 2018 GlobalLogic
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#-------------------------------------------------------------------------------
BSP_UBOOT_PATH := $(call my-dir)
UBOOT_CROSS_COMPILE := prebuilts/gcc/linux-x86/arm/gcc-linaro_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

UBOOT_SRC := external/u-boot
UBOOT_OUT := $(PRODUCT_OUT)/obj/UBOOT_OBJ

UBOOT_KCFLAGS = \
    -fgnu89-inline \
    $(TARGET_BOOTLOADER_CFLAGS)

UMAKE := \
    PATH=/usr/bin:/bin:$$PATH \
    CROSS_COMPILE=$$(readlink -f $(UBOOT_CROSS_COMPILE)) \
    ARCH=$(TARGET_ARCH) $(MAKE) \
    -C $(UBOOT_SRC) \
    O=$$(readlink -f $(UBOOT_OUT))

#-------------------------------------------------------------------------------
$(UBOOT_OUT)/u-boot-sunxi-with-spl.bin: $(BSP_UBOOT_PATH)/android.config $(sort $(shell find -L $(UBOOT_SRC)))
	@echo "Building U-Boot: "
	@echo "TARGET_PRODUCT = " $(TARGET_PRODUCT):
	mkdir -p $(UBOOT_OUT)
	$(UMAKE) $(UBOOT_DEFCONFIG)
	PATH=/usr/bin:/bin $(UBOOT_SRC)/scripts/kconfig/merge_config.sh -m -O $(UBOOT_OUT)/ $(UBOOT_OUT)/.config $<
	$(UMAKE) olddefconfig
	$(UMAKE) KCFLAGS="$(UBOOT_KCFLAGS)"

$(UBOOT_OUT)/boot.scr: $(BSP_UBOOT_PATH)/boot.txt $(UBOOT_OUT)/u-boot-sunxi-with-spl.bin
	$(UBOOT_OUT)/tools/mkimage -A arm -O linux -T script -C none -a 0 -e 0 -d $< $@

$(UBOOT_OUT)/boot_net.scr: $(BSP_UBOOT_PATH)/boot_net.txt $(UBOOT_OUT)/u-boot-sunxi-with-spl.bin
	$(UBOOT_OUT)/tools/mkimage -A arm -O linux -T script -C none -a 0 -e 0 -d $< $@

#-------------------------------------------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := u-boot-sunxi-with-spl.bin

LOCAL_MODULE_PATH := $(PRODUCT_OUT)
LOCAL_PREBUILT_MODULE_FILE:= $(UBOOT_OUT)/$(LOCAL_MODULE)

include $(BUILD_EXECUTABLE)

#-------------------------------------------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := boot.scr

LOCAL_MODULE_PATH := $(PRODUCT_OUT)
LOCAL_PREBUILT_MODULE_FILE:= $(UBOOT_OUT)/$(LOCAL_MODULE)

include $(BUILD_EXECUTABLE)

#-------------------------------------------------------------------------------
include $(CLEAR_VARS)

LOCAL_MODULE := boot_net.scr

LOCAL_MODULE_PATH := $(PRODUCT_OUT)
LOCAL_PREBUILT_MODULE_FILE:= $(UBOOT_OUT)/$(LOCAL_MODULE)

include $(BUILD_EXECUTABLE)

#-------------------------------------------------------------------------------
