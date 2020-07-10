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
fvctl -f /dev/null add-slice video tcp:localhost:10001 admin@videoslice
fvctl -f /dev/null add-slice voip tcp:localhost:10002 admin@voipslice
fvctl -f /dev/null add-slice best-effort tcp:localhost:10003 admin@besteffortslice

# Check defined slices
fvctl -f /dev/null list-slices

# Define flowspaces

# switch lx edge
fvctl -f /dev/null add-flowspace dpid1-port-video-src 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_src=9999 video=7
fvctl -f /dev/null add-flowspace dpid1-port-video-dst 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9999 video=7

fvctl -f /dev/null add-flowspace dpid1-port-voip-src 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9998 voip=7
fvctl -f /dev/null add-flowspace dpid1-port-voip-dst 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9998 voip=7

fvctl -f /dev/null add-flowspace dpid1-port-besteffort 1 1 in_port= best-effort=7


fvctl -f /dev/null add-flowspace dpid1-port-video-src 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_src=9999 video=7
fvctl -f /dev/null add-flowspace dpid1-port-video-dst 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9999 video=7

fvctl -f /dev/null add-flowspace dpid1-port-voip-src 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9998 voip=7
fvctl -f /dev/null add-flowspace dpid1-port-voip-dst 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9998 voip=7

fvctl -f /dev/null add-flowspace dpid1-port-besteffort 1 1 in_port= best-effort=7


# switch rx edge
fvctl -f /dev/null add-flowspace dpid5-port-video-src 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_src=9999 video=7
fvctl -f /dev/null add-flowspace dpid5-port-video-dst 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9999 video=7

fvctl -f /dev/null add-flowspace dpid5-port-voip-src 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9998 voip=7
fvctl -f /dev/null add-flowspace dpid5-port-voip-dst 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9998 voip=7

fvctl -f /dev/null add-flowspace dpid5-port-besteffort 1 1 in_port= best-effort=7


fvctl -f /dev/null add-flowspace dpid5-port-video-src 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_src=9999 video=7
fvctl -f /dev/null add-flowspace dpid5-port-video-dst 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9999 video=7

fvctl -f /dev/null add-flowspace dpid5-port-voip-src 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9998 voip=7
fvctl -f /dev/null add-flowspace dpid5-port-voip-dst 1 100 in_port=,dl_type=0x0800,nw_proto=6,tp_dst=9998 voip=7

fvctl -f /dev/null add-flowspace dpid5-port-besteffort 1 1 in_port= best-effort=7


# internal switches
fvctl -f /dev/null add-flowspace dpid1-port-video 1 100 in_port= video=7
fvctl -f /dev/null add-flowspace dpid1-port-voip 1 100 in_port= voip=7
fvctl -f /dev/null add-flowspace dpid1-port-best-effort 1 100 in_port= best-effort=7


fvctl -f /dev/null add-flowspace dpid2-video 1 100 any video=7

fvctl -f /dev/null add-flowspace dpid3-voip 1 100 any voip=7

fvctl -f /dev/null add-flowspace dpid4-best-effort 1 1 any best-effort=7


fvctl -f /dev/null add-flowspace dpid5-port-video 1 100 in_port= video=7
fvctl -f /dev/null add-flowspace dpid5-port-voip 1 100 in_port= voip=7
fvctl -f /dev/null add-flowspace dpid5-port-best-effort 1 100 in_port= best-effort=7

# Check all the flowspaces added
fvctl -f /dev/null list-flowspace


## CLEANUP
fvctl -f /dev/null remove-slice upper
fvctl -f /dev/null remove-slice middle
fvctl -f /dev/null remove-slice lower

## CHECK CLEANUP PERFORMED
fvctl -f /dev/null list-slices
fvctl -f /dev/null list-flowspace
