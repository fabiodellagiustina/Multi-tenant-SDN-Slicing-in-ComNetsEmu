# Multi-tenant SDN Slicing in ComNetsEmu
*Softwarized and Virtualized Mobile Networks A.Y. 2019/2020 - UniTN*

**Andrea Abriani** - _Mat. 214978_  
**Fabio Della Giustina** - _Mat. 214979_  
**Davide Gagliardi** - _Mat. 214958_


## Building blocks

- **Open vSwitch (v2.7)**: open-source multi-layer virtual switch manager that allows the communication between "dumb switches" and controllers.
- **RYU (v4.34)**: component-based Software Defined Networking framework implemented in Python that provides a simple way to define control functionalities for an OpenFlow controller.
- **FlowVisor (v1.4)**: special purpose OpenFlow controller that acts as a transparent proxy between OpenFlow switches and multiple OpenFlow controllers.


## Implementation

![alt text](Implementation.png "Implementation")

- **Topology** (hosts and switches): defined in ComNetsEmu.
- **FlowVisor** (core controller): stands in between the switches and the tenant controllers; defines the slices to which one RYU controller is assigned each (enabling multi-tenancy); policy checks each OpenFlow message that goes through it, checking permissions related to the policies defined.
- **RYU controllers** (tenant controllers): defined in ComNetsEmu.

*Note*: FlowVisor v1.4 (last open-source version available) is based on OpenFlow 1.0, thus both the Open vSwitch switches and the RYU controllers need to be set up working with OpenFlow 1.0.

### Integrating FlowVisor in ComNetsEmu

Since FlowVisor is quite old and outdated, it needs to be implemented in a Docker container running an old CentOS image with an old version of Java (required by FlowVisor).

## Topologies
### First topology

![alt text](Topology1.png "First topology")

First topology presents 3 slices (topology slicing): upper, middle, and lower.
- Upper: tenant controller forwards traffic based on direction (left-to-right and right-to-left, via Switch 3 and Switch 4 respectively).
- Middle: tenant controller implements simple forwarding, flows are set up during configuration phase.
- Lower: tenant controller implements simple forwarding, flows are set up during operational phase.

#### Demo
Start up ComNetsEmu VM `vagrant up comnetsemu` and log into it `vagrant ssh comnetsemu`.

##### Setting up the topology (Mininet)
Set up the topology with Mininet:
```bash
vagrant@comnetsemu:~/comnetsemu/SVMN_project/1st_scenario $ sudo mn -c  # To flush any previous configurations
vagrant@comnetsemu:~/comnetsemu/SVMN_project/1st_scenario $ sudo python3 first-topology.py
```

##### Setting up the core controller (FlowVisor)
In a new terminal.

The first time, build the FlowVisor image:
```bash
vagrant@comnetsemu:~/comnetsemu/SVMN_project/flowvisor $ ./build_flowvisor_image.sh
```

Run the Flowvisor container:
```bash
vagrant@comnetsemu:~/comnetsemu/SVMN_project/flowvisor $ ./run_flowvisor_container.sh

[root@comnetsemu ~] cd slicing_scripts
[root@comnetsemu slicing_scripts] ./1st-flowvisor_slicing.sh  # Press ENTER when a slice password is required (empty password)
```

##### Setting up the tenant controllers (RYU)
Open a new terminals for each controller.

Upper slice controller:
```bash
vagrant@comnetsemu:~/comnetsemu/SVMN_project/1st_scenario $ ryu run --observe-links --ofp-tcp-listen-port 10001 --wsapi-port 8082 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-upperslice.py
```

Middle slice controller:
```bash
vagrant@comnetsemu:~/comnetsemu/SVMN_project/1st_scenario $ ryu run --observe-links --ofp-tcp-listen-port 10002 --wsapi-port 8083 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-middleslice.py
```

Lower slice controller:
```bash
vagrant@comnetsemu:~/comnetsemu/SVMN_project/1st_scenario $ ryu run --observe-links --ofp-tcp-listen-port 10003 --wsapi-port 8084 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-lowerslice.py
```

Check the status of each slice infrastructure:
- Upper slice: [0.0.0.0:8082](http://0.0.0.0:8082)
- Middle slice: [0.0.0.0:8083](http://0.0.0.0:8083)
- Lower slice: [0.0.0.0:8084](http://0.0.0.0:8084)

##### Testing reachability

Perfom a ping from Host 1 to Host 4:
```bash
mininet> h1 ping h4
```

Check flows inserted in Switch 3 and Switch 4:
```bash
sudo ovs-ofctl dump-flows s3
sudo ovs-ofctl dump-flows s4
```

Perform a ping from Host 2 to Host 5:
```bash
mininet> h2 ping h5
```

Perform a ping from Host 3 to Host 6:
```bash
mininet> h3 ping h6
```

**IMPORTANT**: Before moving to another scenario it is strongly recommended to flush everything with `sudo mn -c` and stop the VM with `vagrant halt comnetsemu`.


### Second topology

![alt text](Topology2.png "Second topology")

The second topology presents 2 slices, namely upper and lower slice.

In the upper slice, the tenant controller discriminates traffic based on whether the flows are UDP flows on port 9999. If that is the case, traffic will pass through Switch 3, otherwise traffic will pass through Switch 4.

In the lower slice, the tenant controller applies packet flooding for all traffic flowing through the switches.

#### Demo

First, run the VM with the command `vagrant up comnetsemu` and log in `vagrant ssh comnetsemu`.

###### Mininet
Set up the whole environment with mininet. Navigate to the correct folder and run the mininet script:

```bash
vagrant@comnetsemu:~$  cd comnetsemu/SVMN_project/2nd_scenario
vagrant@comnetsemu:~/comnetsemu/SVMN_project/2nd_scenario $ sudo mn -c #to flush eventual previous configurations
vagrant@comnetsemu:~/comnetsemu/SVMN_project/2nd_scenarioo $ sudo python3 second-topology.py
```
###### Flowvisor
In a new terminal, run the Flowvisor container with the following commands:
```bash
vagrant@comnetsemu:~$ cd comnetsemu/SVMN_project/flowvisor

#If it's the first time you need to build the flowvisor image, typing this command
vagrant@comnetsemu:~/comnetsemu/SVMN_project/flowvisor $ ./build_flowvisor_image.sh

#Then you will be able to launch the container
vagrant@comnetsemu:~/comnetsemu/SVMN_project/flowvisor $ ./run_flowvisor_container.sh

#Launch the Flowvisor script to set up the slices, press ENTER when a password for the slice is required
[root@comnetsemu ~] cd slicing_scripts
[root@comnetsemu slicing_scripts] ./2nd-flowvisor_slicing.sh

```

###### Setup Controllers
Open two different terminal windows, log into the VM and navigate to the correct folder with the command `cd comnetsemu/SVMN_project/2nd_scenario`.
Then you will be able to run the controllers.

Run UpperSlice Controller:
```bash
vagrant@comnetsemu:~/comnetsemu/SVMN_project/2nd_scenario $ ryu run --observe-links --ofp-tcp-listen-port 10001 --wsapi-port 8082 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-upperslice.py
```

Run LowerSlice Controller:
```bash
vagrant@comnetsemu:~/comnetsemu/SVMN_project/2nd_scenario $ ryu run --observe-links --ofp-tcp-listen-port 10002 --wsapi-port 8083 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-lowerslice.py
```
It is possible to check the status of the infrastructure opening a browser tab with the following addressed:
- Upper slice: [0.0.0.0:8082](http://0.0.0.0:8082)
- Lower slice: [0.0.0.0:8083](http://0.0.0.0:8083)



###### UpperSlice Concept Demonstration

**A)**

Run Simple Command:
```bash
mininet> xterm h1
mininet> xterm h5
xterm-h5> iperf -s -u -p 9999
xterm-h1> iperf -c 10.0.0.5 -u -p 9999 -t 10 -i 1
```

Show flow entries installed on Switch 3 and Switch 4
```bash
sudo ovs-ofctl dump-flows s3
sudo ovs-ofctl dump-flows s4
```

**B)**

Run Simple Command
```bash
xterm-h5> iperf -s -p 9999
xterm-h1> iperf -c 10.0.0.5 -p 9999 -t 10 -i 1
```

Show flow entries installed on Switch 3 and Switch 4
```bash
sudo ovs-ofctl dump-flows s3
sudo ovs-ofctl dump-flows s4
```



###### LowerSlice Concept Demonstration

Run Simple Command  (demonstrates that slice is operational while switches are set up to flood every packet they receive)
```bash
mininet> xterm h3
mininet> xterm h7
xterm-h7> iperf -s -u -p 9999
xterm-h3> iperf -c 10.0.0.7 -u -p 9999 -t 10 -i 1
```
or
```bash
xterm-h3> telnet 10.0.0.7 65000
xterm-h3> telnet 10.0.0.4 65000
xterm-h3> telnet 10.0.0.8 65000
```
Before moving to a next scenario it is strongly recommended to flush everything with the command `sudo mn -c` and stop the VM with `vagrant halt comnetsemu`.


### Third topology

![alt text](Topology3.png "Third topology")

The third topology uses a different approach. Indeed, FlowVisor implements a service slicing mechanism than a topology slicing one. Thus, FlowVisor assigns different traffic to different slices based on the kind of traffic flowing (even through the same port). This is done discriminating onto the type of protocol or port used.

In this scenario, 3 different tenant controllers, when independently called by FlowVisor, redirect traffic through a different intermediate switch. Namely, the upper slice controller is called to handle TCP traffic on port 9999, the middle one to handle UDP traffic on port 9998 and the lower one to handle all the other traffic.

#### Demo
First, you need to run the VM with the command `vagrant up comnetsemu` and log in `vagrant ssh comnetsemu`

###### Mininet
Set up the whole environment with Mininet. Navigate to the correct folder and run the Mininet script:
```bash
vagrant@comnetsemu:~$  cd comnetsemu/SVMN_project/3rd_scenario
vagrant@comnetsemu:~/comnetsemu/SVMN_project/3rd_scenario $ sudo mn -c #to flush eventual previous configurations
vagrant@comnetsemu:~/comnetsemu/SVMN_project/3rd_scenario $ sudo python3 third-topology.py
```
###### Flowvisor
In a new terminal, run the flowvisor container with the following commands:
```bash
vagrant@comnetsemu:~$ cd comnetsemu/SVMN_project/flowvisor

#If it's the first time you need to build the flowvisor image, typing this command
vagrant@comnetsemu:~/comnetsemu/SVMN_project/flowvisor $ ./build_flowvisor_image.sh

#Then you will be able to launch the container
vagrant@comnetsemu:~/comnetsemu/SVMN_project/flowvisor $ ./run_flowvisor_container.sh

#Launch the Flowvisor script to set up the slices, press ENTER when a password for the slice is required
[root@comnetsemu ~] cd slicing_scripts
[root@comnetsemu slicing_scripts] ./3rd-flowvisor_slicing.sh
```  


###### Setup Controllers
Open three different terminal windows, log into the VM and navigate to the correct folder with the command `cd comnetsemu/SVMN_project/3rd_scenario`.
Then you will be able to run the controllers.

Run UpperSlice Controller:
```bash
vagrant@comnetsemu:~/comnetsemu/SVMN_project/3rd_scenario $ ryu run --observe-links --ofp-tcp-listen-port 10001 --wsapi-port 8082 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-upperslice.py
```

Run MiddleSlice Controller:
```bash
vagrant@comnetsemu:~/comnetsemu/SVMN_project/3rd_scenario $ ryu run --observe-links --ofp-tcp-listen-port 10002 --wsapi-port 8083 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-middleslice.py
```

Run LowerSlice Controller:
```bash
vagrant@comnetsemu:~/comnetsemu/SVMN_project/3rd_scenario $ ryu run --observe-links --ofp-tcp-listen-port 10003 --wsapi-port 8084 /usr/local/lib/python3.6/dist-packages/ryu/app/gui_topology/gui_topology.py ryu-lowerslice.py
```
It is possible to check the status of the infrastructure opening a browser tab with the following addressed:
- Upper slice: [0.0.0.0:8082](http://0.0.0.0:8082)
- Middle slice: [0.0.0.0:8083](http://0.0.0.0:8083)
- Lower slice: [0.0.0.0:8084](http://0.0.0.0:8084)


###### UpperSlice Concept Demonstration

Run Simple Command
```bash
mininet> xterm h1
mininet> xterm h2
```

```bash
iperf -s -p 9999
iperf -c 10.0.0.2 -p 9999 -t 10 -i 1
```

Show flow entries installed on Switch 2, Switch 3 and Switch 4
```bash
sudo ovs-ofctl dump-flows s2
sudo ovs-ofctl dump-flows s3
sudo ovs-ofctl dump-flows s4
```

###### MiddleSlice Concept Demonstration

Run Simple Command
```bash
mininet> xterm h1
mininet> xterm h2
```
```bash
iperf -s -u -p 9998
iperf -c 10.0.0.2 -u -p 9998 -t 10 -i 1
```

Show flow entries installed on Switch 2, Switch 3 and Switch 4
```bash
sudo ovs-ofctl dump-flows s3
sudo ovs-ofctl dump-flows s2
sudo ovs-ofctl dump-flows s4
```


###### LowerSlice Concept Demonstration

Run Simple Command
```bash
mininet> xterm h1
mininet> xterm h2
```
```bash
iperf -s -u -p 9990
iperf -c 10.0.0.2 -u -p 9990 -t 10 -i 1
```

Show flow entries installed on Switch 2, Switch 3 and Switch 4
```bash
sudo ovs-ofctl dump-flows s2
sudo ovs-ofctl dump-flows s3
sudo ovs-ofctl dump-flows s4
```

Before moving to a next scenario it is strongly recommended to flush everything with the command `sudo mn -c` and stop the VM with `vagrant halt comnetsemu`.


## Known issues

An issue was found during the project. It is related to the forwarding OpenFlow packet_out messages when commanded by the OpenFlow tenant controller to the switches. This kind of error takes place only in switches that are shared among two or more slices in the FlowVisor definition. More specifically, the pattern we found shows no issues on the first controller assigned to the shared switch, instead manifesting itself for all subsequent controllers assigned to it within FlowVisor.

As an example, this issue may arise in the First topology exposed, from the handling by the middle slice tenant controller to command a packet_out message to Switch 4 (which is shared with the upper slice). That would generate an error, illustrated below, of type "bad permissions" on the switch.

```bash
EVENT ofp_event->NoFlowEntry EventOFPPacketIn
INFO packet arrived in s4 (in_port=2)
INFO sending packet from s4 (out_port=4)
EventOFPErrorMsg received.
version=0x1, msg_type=0x1, msg_len=0x6a, xid=0x0
 `-- msg_type: OFPT_ERROR(1)
OFPErrorMsg(type=0x2, code=0x6, data=b'\x01\x0d\x00\x5e\xa8\x8c\x25\x6d\xff\xff\xff\xff\x00\x02\x00\x08\x00\x00\x00\x08\x00\x04\xff\xe5\x33\x33\x00\x00\x00\x02\x8a\x52\x84\x58\x39\x17\x86\xdd\x60\x00\x00\x00\x00\x10\x3a\xff\xfe\x80\x00\x00\x00\x00\x00\x00\x88\x52\x84\xff\xfe\x58\x39\x17\xff\x02\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x85\x00\xef\xa9\x00\x00\x00\x00\x01\x01\x8a\x52\x84\x58\x39\x17')
 |-- type: OFPET_BAD_ACTION(2)
 |-- code: OFPBAC_EPERM(6)
 `-- data: version=0x1, msg_type=0xd, msg_len=0x5e, xid=0xa88c256d
     `-- msg_type: OFPT_PACKET_OUT(13)
```

Even analyzing the behaviour thanks to Wireshark we integrated into the VM, we have not been able to tackle further this issue. On Wireshark a missing ICMP response highlights when dissecting the packet_out message information, but still the same situation happens also on the upper slice, which instead runs unaffected.

![alt text](Wireshark_capture.png "Wireshark capture")

It is worth noting that the whole project was developed only on a L2 level, ignoring the packet loss checking that is usually performed by applications on the application level.
Without considering that, as an escamotage, on the problematic slices the forwarding rules are assigned on the configuration phase between tenant controller and switch, in order to avoid the loss of the first packets that would otherwise not be sent back from the switch because of the issue (as implemented for the middle controller of the First topology).
As another solution, it may have been interesting to evaluate the outcome when adopting the packet buffering on the switch, thus avoiding the sending of packet data back and forth between the controller and switch. However, this was not possible because the OpenvSwitch version used in the switches (Open vSwitch v2.7), is lacking the buffering feature (removed from Open vSwitch v2.5). On the other hand, we did not proceed to downgrade OpenvSwitch in order to avoid further problematics that may arise from it.
