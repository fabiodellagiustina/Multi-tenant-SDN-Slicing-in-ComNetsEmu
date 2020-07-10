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
