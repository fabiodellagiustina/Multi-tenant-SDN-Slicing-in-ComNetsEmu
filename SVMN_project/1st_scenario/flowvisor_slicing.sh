#!/bin/bash

# Start FlowVisor service
sudo /etc/init.d/flowvisor start

sleep 10

# Get FlowVisor current config
fvctl -f /etc/flowvisor/flowvisor.passwd get-config

# Get FlowVisor current defined slices
fvctl -f /etc/flowvisor/flowvisor.passwd list-slices

# Get FlowVisor current defined flowspaces
fvctl -f /etc/flowvisor/flowvisor.passwd list-flowspace

# Get FlowVisor connected switches
fvctl -f /etc/flowvisor/flowvisor.passwd list-datapaths

# Get FlowVisor connected switches links up
fvctl -f /etc/flowvisor/flowvisor.passwd list-links

# Define the FlowVisor slices
fvctl -f /etc/flowvisor/flowvisor.passwd add-slice upper tcp:localhost:10001 admin@upperslice
fvctl -f /etc/flowvisor/flowvisor.passwd add-slice middle tcp:localhost:10002 admin@middleslice
fvctl -f /etc/flowvisor/flowvisor.passwd add-slice lower tcp:localhost:10003 admin@lowerslice

# Check defined slices
fvctl -f /etc/flowvisor/flowvisor.passwd list-slices

# Define flowspaces
fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid1 1 1 any upper=7

fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid2-port3 2 1 in_port=3 middle=7
fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid2-port1 2 1 in_port=1 middle=7

fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid2-port2 2 1 in_port=2 lower=7
fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid2-port4 2 1 in_port=4 lower=7

fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid3 3 1 any upper=7

fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid4-port1 4 1 in_port=1 upper=7
fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid4-port3 4 1 in_port=3 upper=7

fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid4-port2 4 1 in_port=2 middle=7
fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid4-port4 4 1 in_port=4 middle=7

fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid5 5 1 any lower=7

fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid6 6 1 any upper=7

fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid7-port1 7 1 in_port=1 middle=7
fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid7-port3 7 1 in_port=3 middle=7

fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid7-port2 7 1 in_port=2 lower=7
fvctl -f /etc/flowvisor/flowvisor.passwd add-flowspace dpid7-port4 7 1 in_port=4 lower=7

# Check all the flowspaces added
fvctl -f /etc/flowvisor/flowvisor.passwd list-flowspace


## CLEANUP
#fvctl -f /etc/flowvisor/flowvisor.passwd remove-slice upper
#fvctl -f /etc/flowvisor/flowvisor.passwd remove-slice middle
#fvctl -f /etc/flowvisor/flowvisor.passwd remove-slice lower

## CHECK CLEANUP PERFORMED
#fvctl -f /etc/flowvisor/flowvisor.passwd list-slices
#fvctl -f /etc/flowvisor/flowvisor.passwd list-flowspace
