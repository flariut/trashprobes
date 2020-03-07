#!/bin/bash
sudo airmon-ng check kill
sudo ifconfig wlp3s0 down && sudo iwconfig wlp3s0 mode Monitor && sudo ifconfig wlp3s0 up
