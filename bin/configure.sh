#!/usr/bin/env bash
set -o errexit -o errtrace -o nounset -o pipefail

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
