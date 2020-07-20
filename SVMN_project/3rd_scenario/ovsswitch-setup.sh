#!/bin/bash
#
# About: Set OpenFlow v1.0 to all the OVSSwitches spawned within Mininet for compatibility w/ FlowVisor
#

echo "Setting s1 to OF 1.0..."
sudo ovs-vsctl set bridge s1 protocols=OpenFlow10
echo "Setting s2 to OF 1.0..."
sudo ovs-vsctl set bridge s2 protocols=OpenFlow10
echo "Setting s3 to OF 1.0..."
sudo ovs-vsctl set bridge s3 protocols=OpenFlow10
echo "Setting s4 to OF 1.0..."
sudo ovs-vsctl set bridge s4 protocols=OpenFlow10
echo "Setting s5 to OF 1.0..."
sudo ovs-vsctl set bridge s5 protocols=OpenFlow10

echo "DONE."

# Execute flow entries lookup
#sudo ovs-ofctl -O OpenFlow10 dump-flows s3
#sudo ovs-ofctl --protocols=OpenFlow10 dump-flows s4
