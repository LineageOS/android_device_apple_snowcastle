#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/generic_no_telephony.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_mini_go_phone.mk)

# Inherit from device
PRODUCT_IS_GO := true
$(call inherit-product, device/apple/snowcastle/device.mk)

PRODUCT_NAME := lineage_snowcastle_legacy
PRODUCT_DEVICE := snowcastle_legacy
PRODUCT_BRAND := Apple
PRODUCT_MANUFACTURER := Apple
PRODUCT_MODEL := Snowcastle (Legacy)
