#!/bin/bash
#
# About: Run FlowVisor docker image with host networking and interactive mode
#
# WARNING: This is an old script with an absolute path, run the command with the relative path instead as described in the README.
#

docker run -v /home/vagrant/comnetsemu/SVMN_project/flowvisor/slicing_scripts:/root/slicing_scripts -it --rm --network host flowvisor:latest /bin/bash
