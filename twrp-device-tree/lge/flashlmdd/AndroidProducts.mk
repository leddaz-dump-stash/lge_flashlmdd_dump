#
# Copyright (C) 2022 The Android Open Source Project
# Copyright (C) 2022 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

PRODUCT_MAKEFILES := \
    $(LOCAL_DIR)/omni_flashlmdd.mk

COMMON_LUNCH_CHOICES := \
    omni_flashlmdd-user \
    omni_flashlmdd-userdebug \
    omni_flashlmdd-eng
