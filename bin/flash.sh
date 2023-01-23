#!/usr/bin/env bash
set -o errexit -o errtrace -o nounset -o pipefail

echo "Ensure the Turing Pi is powered on and connected via USB."
if ! gum confirm "Ready to begin?"; then
    echo "Aborting."
    exit 1
fi

sudo ./usbboot/rpiboot
echo "Wating for device to mount."
if ! gum confirm "Continue?"; then
    echo "Aborting."
    exit 1
fi

devices="$(diskutil list -plist external physical | plutil -extract WholeDisks json -o - - | jq -r '.[]')"
if [[ "${devices}" == "" ]]; then
    echo "No devices available to flash."
    exit 1
fi

echo ""
diskutil list external physical

echo "Select a device to flash:"
device="$(echo "${devices}" | gum choose)"
echo ""

if [[ "${device}" == "" ]]; then
    echo "No device selected."
    exit 1
fi

if ! gum confirm "Preparing to unmount and flash ${device}; Continue?"; then
    echo "Aborting."
    exit 1
fi

echo "Flashing ${device}"
diskutil unmountDisk "/dev/${device}"
pv ./images/raspios.img | sudo dd "bs=1m" "of=/dev/r${device}"

./bin/configure.sh

echo "Unmounting ${device}"
diskutil unmountDisk "/dev/${device}"
