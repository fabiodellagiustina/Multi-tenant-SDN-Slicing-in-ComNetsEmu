#!/bin/bash
#
# About: Run Wireshark docker image with host networking and GUI
#

docker run -v /home/vagrant/comnetsemu/SVMN_project/wireshark/captures:/root/wireshark/captures --net=host --env="DISPLAY" --volume="$HOME/.Xauthority:/root/.Xauthority:rw" wireshark:latest
