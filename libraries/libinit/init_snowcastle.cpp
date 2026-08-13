/*
 * Copyright (C) 2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include "vendor_init.h"

#include <libinit_mainline_common.h>
#include <libinit_misc.h>
#include <libinit_utils.h>

#include <string>
#include <unordered_map>

static constexpr char kDtBasePath[] = "/sys/firmware/devicetree/base/";

static const std::unordered_map<std::string, std::string> kDtPathToPropertyMap = {
        {"chosen/asahi,iboot2-version", "ro.bootloader"},
        {"smbios/smbios/baseboard/product", "ro.boot.hardware.revision"},
        {"smbios/smbios/system/serial", "ro.serialno"},
};

void vendor_process_bootenv() {
    vendor_process_bootenv_mainline_common();
    enable_insecure_debugging();
}

void vendor_load_properties() {
    vendor_load_properties_mainline_common();

    for (const auto& [path, prop] : kDtPathToPropertyMap) {
        set_prop_from_file(prop, kDtBasePath + path);
    }
}
