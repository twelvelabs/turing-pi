#!/usr/bin/env bash
set -o errexit -o errtrace -o nounset -o pipefail

# Resolve inputs
CMID="${CMID:-}"
if [[ "${CMID}" == "" ]]; then
    echo "Which compute module is this?"
    CMID="$(gum choose {1..7})"
fi

SSID="${SSID:-}"
if [[ "${SSID}" == "" ]]; then
    echo "Wifi SSID:"
    SSID="$(gum input)"
fi

PSK="${PSK:-}"
if [[ "${PSK}" == "" ]]; then
    echo "Wifi WPA-PSK (password):"
    PSK="$(gum input)"
fi

# Wait for boot volume to mount
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

# Configure static ip address
# See: https://raspberrypi.stackexchange.com/a/136637
sed "1 s/\$/ ip=172.16.1.20${CMID}::172.16.1.1:255.255.255.0:rpi:eth0:off/" /Volumes/boot/cmdline.txt >/Volumes/boot/cmdline.txt.tmp
mv /Volumes/boot/cmdline.txt.tmp /Volumes/boot/cmdline.txt

# Enable SSH
touch /Volumes/boot/ssh

# Add a user account
# user: pi
# password: raspberry
user="pi:\$6\$/4.VdYgDm7RJ0qM1\$FwXCeQgDKkqrOU3RIRuDSKpauAbBvP11msq9X58c8Que2l1Dwq3vdJMgiZlQSbEXGaY5esVHGBNbCxKLVNqZW1"
echo "${user}" >/Volumes/boot/userconf.txt

# Configure Wifi
country="$(defaults read /Library/Preferences/.GlobalPreferences.plist Country)"
cat <<EOF >>/Volumes/boot/wpa_supplicant.conf
country=${country}
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    scan_ssid=1
    ssid="${SSID}"
    psk="${PSK}"
    proto=RSN
    key_mgmt=WPA-PSK
    pairwise=CCMP
    auth_alg=OPEN
}
EOF
