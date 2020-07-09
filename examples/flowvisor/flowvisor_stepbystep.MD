# Activating correctly FlowVisor: Step by step

## 1 - Preparing FlowVisor

To correctly run FlowVisor, an obsolete set of bins/libs needs to be installed. Since in ComNetsEmu environment this would lead to incompatibility, Docker is exploited to provide an isolated FlowVisor environment with all the necessary components.

Let's define a custom Dockerfile (that we will call _Dockerfile.flowvisor_) to generate the FlowVisor environment needed:
```bash
#
# About: Image for FlowVisor: A transparent proxy between OpenFlow switches and multiple OpenFlow controllers
#

FROM centos:6.10

RUN yum update -y && yum install wget sudo nano -y

WORKDIR /root

RUN wget http://updates.onlab.us/GPG-KEY-ONLAB

RUN rpm --import GPG-KEY-ONLAB

RUN echo -e "[onlab] \nname=ON.Lab Software Releases \nbaseurl=http://updates.onlab.us/rpm/stable \nenabled=1 \ngpgcheck=1" >> /etc/yum.repos.d/onlab.repo

RUN yum update -y

RUN yum install vim-enhanced -y

RUN yum install flowvisor -y

ENV TERM=vt100

ENV HOME /root

ENV BUILD_NUMBER docker

CMD ["bash"]

```

Then build the Docker image from the folder in which _Dockerfile.flowvisor_ is present:
```bash
docker build --rm -t flowvisor:latest -f ./Dockerfile.flowvisor .
```

Finally, start a Docker container from the image just created:
```bash
docker run -it --rm --network host flowvisor:latest /bin/bash
```
__Note__: In order to use FlowVisor appropriately, the container is run with host network mode, namely sharing the network stack of the host OS (in our case Vagrant's ComNetsEmu network stack). So inside the FlowVisor container, the FlowVisor can listen on a host's address which is configured for SDN switches
to connect. Then the SDN controller can connect to FlowVisor.

Now, the terminal is running in interacting mode with the FlowVisor container.
From the terminal, generate a flowvisor config:
```bash
sudo -u flowvisor fvconfig generate /etc/flowvisor/config.json
```

When asked for the fvadmin password, leave it blank (by just hitting enter).

To be able to set the config up correctly, start FlowVisor:
```bash
sudo /etc/init.d/flowvisor start
```

Enable the FlowVisor topology controller using fvctl, which is a command-line utility to manage FlowVisor. The -f argument points to a password file. FlowVisor instance has been configured passwordless, therefore the password file is /dev/null.

```bash
fvctl -f /dev/null set-config --enable-topo-ctrl
```

Restart FlowVisor:
```bash
sudo /etc/init.d/flowvisor restart
```

For now, stop FlowVisor. We will later use it to operate.
```bash
sudo /etc/init.d/flowvisor stop
```


## 2 - Preparing Mininet
Let's define a custom Mininet topology based on 4 switches:
```python
#!/usr/bin/python

from mininet.topo import Topo

class FVTopo(Topo):

    def __init__(self):
        # Initialize topology
        Topo.__init__(self)

        # Create template host, switch, and link
        hconfig = {'inNamespace':True}
        http_link_config = {'bw': 1}
        video_link_config = {'bw': 10}
        host_link_config = {}

        # Create switch nodes
        for i in range(4):
            sconfig = {'dpid': "%016x" % (i+1)}
            self.addSwitch('s%d' % (i+1), **sconfig)

        # Create host nodes
        for i in range(4):
            self.addHost('h%d' % (i+1), **hconfig)

        # Add switch links
        self.addLink('s1', 's2', **http_link_config)
        self.addLink('s2', 's4', **http_link_config)
        self.addLink('s1', 's3', **video_link_config)
        self.addLink('s3', 's4', **video_link_config)

        # Add host links
        self.addLink('h1', 's1', **host_link_config)
        self.addLink('h2', 's1', **host_link_config)
        self.addLink('h3', 's4', **host_link_config)
        self.addLink('h4', 's4', **host_link_config)

topos = { 'fvtopo': ( lambda: FVTopo() ) }

```

By doing so, we can run it within Mininet legacy commands and options:
```bash
sudo mn --custom flowvisor_topology-example.py --topo fvtopo --link tc --controller=remote,ip=127.0.0.1,port=6633 --mac --arp
```
__Note__: For our application, it is needed to specify operating within a RemoteController (i.e. FlowVisor) by indicating the IP and port to which our Mininet topology listens to. If a RemoteController option is given without specifying IP and port, Mininet defaults to `ip=127.0.0.1,port=6653`

Finally, check whether the Mininet custom topology has been set up and running correctly.

### Setting OpenFlow protocol

As the last version of Mininet, without further specifications, the OVSSwitch switches operating OpenFlow version is v1.5 by default. For this reason, even if everything else is set up correctly, that would generate incompatibility with the FlowVisor (running on OpenFlow v1.0) hence not working.
To be sure of setting OpenFlow v1.0 on the OVSSwitch switches, run the correspondent `ovs-vctl` command per each switch on a new terminal (while the Mininet custom topology is running).

In our case, 4 switches are considered:
```bash
vagrant@comnetsemu:~$ sudo ovs-vsctl set bridge s1 protocols=OpenFlow10
vagrant@comnetsemu:~$ sudo ovs-vsctl set bridge s2 protocols=OpenFlow10
vagrant@comnetsemu:~$ sudo ovs-vsctl set bridge s3 protocols=OpenFlow10
vagrant@comnetsemu:~$ sudo ovs-vsctl set bridge s4 protocols=OpenFlow10

```


## 3 - Operating within Flowvisor

Now that Mininet topology is set up correctly, let's dive in the FlowVisor environment on the terminal we left still previously.

Because all the configuration needed has been performed in Section 1, we only need to start the FlowVisor service from terminal:
```bash
sudo /etc/init.d/flowvisor start
```

Now, since both Mininet custom topology and FlowVisor (by default) are set to listen to port 6653, all the OVSSwitch of the Mininet topology should have connected to FlowVisor.
Let's verify that by getting FlowVisor configuration:
```bash
fvctl -f /dev/null get-config
```

If FlowVisor is running, we will see the FlowVisor configuration in JSON format like this:
```json
{
  "api_jetty_webserver_port": 8081,
  "api_webserver_port": 8080,
  "checkpointing": false,
  "config_name": "default",
  "db_version": "2",
  "enable-topo-ctrl": true,
  "flood-perm": {
    "dpid": "all",
    "slice-name": "fvadmin"
  },
  "flow-stats-cache": 30,
  "flowmod-limit": {
    "fvadmin": {
      "00:00:00:00:00:00:00:01": -1,
      "00:00:00:00:00:00:00:02": -1,
      "00:00:00:00:00:00:00:03": -1,
      "00:00:00:00:00:00:00:04": -1,
      "any": null
    }
  },
  "host": "localhost",
  "log_facility": "LOG_LOCAL7",
  "log_ident": "flowvisor",
  "logging": "NOTE",
  "stats-desc": false,
  "track-flows": false,
  "version": "flowvisor-1.4.0"
}

```

As we can see, now in addition to the entry `"any": null` for the `"fvadmin"` slice also the dpids of each of the OVSSwitch switches is recorded. Thus, the proper configuration and linking between Mininet and FlowVisor is confirmed.

__Congratulations!__ Now you can manage and control all the tenant controllers by operating within FlowVisor!
