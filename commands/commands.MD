# First Scenario Commands

## Setup Controllers

#### Run UpperSlice Controller
```bash
ryu run --observe-links --ofp-tcp-listen-port 10001 --wsapi-port 8082 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-upperslice.py
```

#### Run MiddleSlice Controller
```bash
ryu run --observe-links --ofp-tcp-listen-port 10002 --wsapi-port 8083 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-middleslice.py
```

#### Run LowerSlice Controller
```bash
ryu run --observe-links --ofp-tcp-listen-port 10003 --wsapi-port 8084 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-lowerslice.py
```



## UpperSlice Concept Demonstration

#### Run Simple Command
```bash
mininet> h1 ping h4
```

#### Show Flows Actually Inserted in Switch 3 and Switch 4 (left-right and right-left flow only respectively)
```bash
sudo ovs-ofctl dump-flows s3
sudo ovs-ofctl dump-flows s4
```



## MiddleSlice Concept Demonstration

#### Run Simple Command  (assesses flow entry applied correctly at config phase)
```bash
mininet> h2 ping h5
```


## LowerSlice Concept Demonstration

#### Run Simple Command  (demonstrates flow entry applied correctly at main phase, but packet_out message generates error in related switch)
```bash
mininet> h3 ping h6
```



# Second Scenario Commands

## Setup Controllers

#### Run UpperSlice Controller
```bash
ryu run --observe-links --ofp-tcp-listen-port 10001 --wsapi-port 8082 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-upperslice.py
```

#### Run LowerSlice Controller
```bash
ryu run --observe-links --ofp-tcp-listen-port 10002 --wsapi-port 8083 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-lowerslice.py
```



## UpperSlice Concept Demonstration

### A)
#### Run Simple Command
```bash
mininet> xterm h1
mininet> xterm h5
xterm-h5> iperf -s -u -p 9999 -b 10M
xterm-h1> iperf -c 10.0.0.5 -u -p 9999 -b 10M -t 10 -i 1
```

#### Show Bidirectional Flows Actually Inserted in Switch 3 (udp.port=9999)
```bash
sudo ovs-ofctl dump-flows s3
```
#### Show No Flows Actually Inserted in Switch 4
```bash
sudo ovs-ofctl dump-flows s4
```

### B)
#### Run Simple Command
```bash
xterm-h5> iperf -s -p 9999 -b 10M
xterm-h1> iperf -c 10.0.0.5 -p 9999 -b 10M -t 10 -i 1
```

#### Show Output Bandwidth Smaller Than Previous Case (because links of the path taken have less bandwidth offered)
#### Show Bidirectional Flows Actually Inserted in Switch 4 (all other traffic except udp.port=9999)
```bash
sudo ovs-ofctl dump-flows s4
```
#### Show No Additional Flows Inserted in Switch 3
```bash
sudo ovs-ofctl dump-flows s3
```



## LowerSlice Concept Demonstration

#### Run Simple Command  (demonstrates that slice is operational while switches are set up to flood every packet they receive)
```bash
mininet> xterm h3
mininet> xterm h7
xterm-h7> iperf -s -u -p 9999 -b 10M
xterm-h3> iperf -c 10.0.0.7 -u -p 9999 -b 10M -t 10 -i 1
```
or
```bash
xterm-h3> telnet 10.0.0.7 65000
xterm-h3> telnet 10.0.0.4 65000
xterm-h3> telnet 10.0.0.8 65000
```




# Third Scenario Commands

## Setup Controllers

#### Run UpperSlice Controller
```bash
ryu run --observe-links --ofp-tcp-listen-port 10001 --wsapi-port 8082 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-upperslice.py
```

#### Run MiddleSlice Controller
```bash
ryu run --observe-links --ofp-tcp-listen-port 10002 --wsapi-port 8083 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-middleslice.py
```

#### Run LowerSlice Controller
```bash
ryu run --observe-links --ofp-tcp-listen-port 10003 --wsapi-port 8084 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-lowerslice.py
```



## UpperSlice Concept Demonstration

#### Run Simple Command
```bash
mininet> h2 iperf -s -p 9999 &
mininet> h1 iperf -c 10.0.0.2 -p 9999 -t 10 -i 1
```

#### Show Bidirectional Flows Actually Inserted in Switch 2
```bash
sudo ovs-ofctl dump-flows s2
```
#### Show No Flows Actually Inserted in Switch 3
```bash
sudo ovs-ofctl dump-flows s3
```
#### Show No Flows Actually Inserted in Switch 4
```bash
sudo ovs-ofctl dump-flows s4
```



## MiddleSlice Concept Demonstration

#### Run Simple Command
```bash
mininet> h2 iperf -s -u -p 9998 &
mininet> h1 iperf -c 10.0.0.2 -u -p 9998 -t 10 -i 1
```

#### Show Output Bandwidth Smaller Than Previous Case (because links of the path taken have less bandwidth offered)
#### Show Bidirectional Flows Actually Inserted in Switch 3
```bash
sudo ovs-ofctl dump-flows s3
```
#### Show No Additional Flows Inserted in Switch 2
```bash
sudo ovs-ofctl dump-flows s2
```
#### Show No Additional Flows Inserted in Switch 4
```bash
sudo ovs-ofctl dump-flows s4
```


## LowerSlice Concept Demonstration

#### Run Simple Command
```bash
mininet> h2 iperf -s -u -p 9990 &
mininet> h1 iperf -c 10.0.0.2 -u -p 9990 -t 10 -i 1
```

#### Show Output Bandwidth Smaller Than Other Previous Cases (because links of the path taken have less bandwidth offered)
#### Show Bidirectional Flows Actually Inserted in Switch 4
```bash
sudo ovs-ofctl dump-flows s4
```
#### Show No Additional Flows Inserted in Switch 2
```bash
sudo ovs-ofctl dump-flows s2
```
#### Show No Additional Flows Inserted in Switch 3
```bash
sudo ovs-ofctl dump-flows s3
```


# Useful commands
Delete all OF flow entries in specific OVSSwitch:
```bash
sudo ovs-ofctl del-flows [switch-name]
```

To monitor OF messages in specific OVSSwitch:
```bash
sudo ovs-ofctl monitor [switch-name]
```
