# Start FlowVisor service
sudo /etc/init.d/flowvisor start

# Get FlowVisor current config
fvctl -f /dev/null get-config

# Get FlowVisor current defined slices
fvctl -f /dev/null list-slices

# Get FlowVisor current defined flowspaces
fvctl -f /dev/null list-flowspace

# Get FlowVisor connected switches
fvctl -f /dev/null list-datapaths

# Get FlowVisor connected switches links up
fvctl -f /dev/null list-links

# Define the FlowVisor slices
fvctl -f /dev/null add-slice upper tcp:localhost:10001 admin@upperslice
fvctl -f /dev/null add-slice middle tcp:localhost:10002 admin@middleslice
fvctl -f /dev/null add-slice lower tcp:localhost:10003 admin@lowerslice

# Check defined slices
fvctl -f /dev/null list-slices

# Define flowspaces
fvctl -f /dev/null add-flowspace dpid1 1 1 any upper=7

fvctl -f /dev/null add-flowspace dpid2-port3 2 1 in_port=3 middle=7
fvctl -f /dev/null add-flowspace dpid2-port1 2 1 in_port=1 middle=7

fvctl -f /dev/null add-flowspace dpid2-port2 2 1 in_port=2 lower=7
fvctl -f /dev/null add-flowspace dpid2-port4 2 1 in_port=4 lower=7

fvctl -f /dev/null add-flowspace dpid3 3 1 any upper=7

fvctl -f /dev/null add-flowspace dpid4-port1 4 1 in_port=1 upper=7
fvctl -f /dev/null add-flowspace dpid4-port3 4 1 in_port=3 upper=7

fvctl -f /dev/null add-flowspace dpid4-port2 4 1 in_port=2 middle=7
fvctl -f /dev/null add-flowspace dpid4-port4 4 1 in_port=4 middle=7

fvctl -f /dev/null add-flowspace dpid5 5 1 any lower=7

fvctl -f /dev/null add-flowspace dpid6 6 1 any upper=7

fvctl -f /dev/null add-flowspace dpid7-port1 7 1 in_port=1 middle=7
fvctl -f /dev/null add-flowspace dpid7-port3 7 1 in_port=3 middle=7

fvctl -f /dev/null add-flowspace dpid7-port2 7 1 in_port=2 lower=7
fvctl -f /dev/null add-flowspace dpid7-port4 7 1 in_port=4 lower=7

# Check all the flowspaces added
fvctl -f /dev/null list-flowspace


## CLEANUP
fvctl -f /dev/null remove-slice upper
fvctl -f /dev/null remove-slice middle
fvctl -f /dev/null remove-slice lower

## CHECK CLEANUP PERFORMED
fvctl -f /dev/null list-slices
fvctl -f /dev/null list-flowspace
