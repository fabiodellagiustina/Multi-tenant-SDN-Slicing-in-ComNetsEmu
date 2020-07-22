# Multi-tenant SDN Slicing in ComNetsEmu
Softwarized and Virtualized Mobile Networks A.Y. 2019/2020 - UniTN

Andrea Abriani - MAT 214978  
Fabio Della Giustina - MAT 214979  
Davide Gagliardi - MAT 214958


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

## First topology

![alt text](Topology1.png "First topology")

The first topology presents 3 slices, namely upper, middle and lower slice. FlowVisor is programmed to topology slice, working on a physical port level.

In the upper slice, the tenant controller forwards traffic based on the direction (Left-to-Right and Right-to-Left, through Switch 3 and Switch 4 respectively).

In both the middle and lower slice, a simple forwarding is implemented by the related tenant controllers, with the difference that flows are installed on the switch during the configuration phase (between tenant controller and switch) for the former and later during the operational phase for the latter.

### Demo

## Second topology

![alt text](Topology2.png "Second topology")

The second topology presents 2 slices, namely upper and lower slice.

In the upper slice, the tenant controller discriminates traffic based on whether the flows are UDP flows on port 9999. If that is the case, traffic will pass through Switch 3, otherwise traffic will pass through Switch 4.

In the lower slice, the tenant controller applies packet flooding for all traffic flowing through the switches.

### Demo


## Third topology

![alt text](Topology3.png "Third topology")

The third topology uses a different approach. Indeed, FlowVisor implements a service slicing mechanism than a topology slicing one. Thus, FlowVisor assigns different traffic to different slices based on the kind of traffic flowing (even through the same port). This is done discriminating onto the type of protocol or port used.

In this scenario, 3 different tenant controllers, when independently called by FlowVisor, redirect traffic through a different intermediate switch. Namely, the upper slice controller is called to handle TCP traffic on port 9999, the middle one to handle UDP traffic on port 9998 and the lower one to handle all the other traffic.

### Demo

## Known issues

An issue was found during the project. It is related to the forwarding OpenFlow packet_out messages when commanded by the OpenFlow tenant controller to the switches. This kind of error takes place only in switches that are shared among two or more slices on the FlowVisor definition. More specifically, the pattern we found shows no issues on the first controller assigned to the shared switch, instead manifesting itself for all subsequent controllers assigned to it within FlowVisor.

As an example, this issue may arise in the First topology exposed, from the handling by the middle slice tenant controller to command a packet_out message to Switch 4 (which is shared with the upper slice). That would generate an error, illustrated below, of type "bad permissions" on the switch.

Even analyzing the behaviour thanks to Wireshark we integrated into the VM, we have not been able to tackle further this issue. On Wireshark a missing ICMP response highlights when dissecting the packet_out message information, but still the same situation happens also on the upper slice, which instead runs unaffected.
It is worth noting that the whole project was developed only on a L2 level, ignoring the packet loss checking that is usually performed by the applications on the application level. But even not considering that, an escamotage, on the problematic slices the forwarding rules are assigned on the config phase between tenant controller and switch, in order to avoid the loss of the first packets that would otherwise not be sent back from the switch because of the issue.
As another solution, it may have been interesting to evaluate the outcome when adopting the packer buffering on the switch, thus avoiding the sending of packet data back and forth between the controller and switch. However, this was not possible because the OpenvSwitch version used in the switches, version 2.7, is lacking the buffering feature, removed from version 2.5. On the other hand, we did not proceed to downgrade OpenvSwitch in order to avoid further problematics that may arise from it.
