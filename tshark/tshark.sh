#!/bin/bash
sudo tshark -o nameres.mac_name:FALSE -l -I -i wlx00c0ca9739ec -Y "wlan.ssid != 0" "wlan type mgt subtype 0100" > ./database
