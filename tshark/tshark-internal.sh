#!/bin/bash
sudo tshark -l -I -i wlp3s0 -Y "wlan.ssid != 0" "wlan type mgt subtype 0100" > ./database
