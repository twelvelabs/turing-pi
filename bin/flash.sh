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

echo "Configuring boot volume"
for i in {0..9}; do
    if [[ -d "/Volumes/boot" ]]; then
        break
    fi
    echo "${i}: Waiting for device boot volume..."
    sleep 1
done

if [[ ! -d "/Volumes/boot" ]]; then
    echo "/Volumes/boot has not mounted after 10 seconds."
    echo "Aborting."
    exit 1
fi

# Enable SSH
touch /Volumes/boot/ssh

# Add a user account
# user: pi
# password: raspberry
user="pi:\$6\$/4.VdYgDm7RJ0qM1\$FwXCeQgDKkqrOU3RIRuDSKpauAbBvP11msq9X58c8Que2l1Dwq3vdJMgiZlQSbEXGaY5esVHGBNbCxKLVNqZW1"
echo "${user}" >/Volumes/boot/userconf.txt

# Configure WiFi
echo "Wifi SSID:"
ssid="$(gum input)"
echo "Wifi PASS:"
pass="$(gum input)"
country="$(defaults read /Library/Preferences/.GlobalPreferences.plist Country)"

cat <<EOF >>/Volumes/boot/wpa_supplicant.conf
country=${country}
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    scan_ssid=1
    ssid="${ssid}"
    psk="${pass}"
    proto=RSN
    key_mgmt=WPA-PSK
    pairwise=CCMP
    auth_alg=OPEN
}
EOF

echo "Unmounting ${device}"
diskutil unmountDisk "/dev/${device}"
