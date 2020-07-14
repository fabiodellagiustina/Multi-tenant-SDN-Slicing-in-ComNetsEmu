#!/usr/bin/python

import os

from comnetsemu.cli import CLI, spawnXtermDocker
from comnetsemu.net import Containernet, VNFManager
from mininet.link import TCLink
from mininet.log import info, setLogLevel
from mininet.node import Controller
from mininet.topo import Topo

class FVTopo(Topo):

    def __init__(self):
        # Initialize topology
        Topo.__init__(self)

        net = Containernet(controller=Controller, link=TCLink, xterms=False)
        mgr = VNFManager(net)

        # Create template host, switch, and link
        hconfig = {'inNamespace':True}
        http_link_config = {'bw': 1}
        video_link_config = {'bw': 10}
        host_link_config = {}

        # Create switch nodes
        for i in range(7):
            sconfig = {'dpid': "%016x" % (i+1)}
            self.addSwitch('s%d' % (i+1), protocols='OpenFlow10', **sconfig)

        # Create host nodes
        for i in range(8):
            self.addDockerHost('h%d' % (i+1), dimage="dev_test", ip="10.0.0.%d" % (i+1), docker_args={"hostname": "h%d" % (i+1)} **hconfig)

        # Add switch links
        self.addLink('s1', 's3', **http_link_config)
        self.addLink('s1', 's4', **http_link_config)
        self.addLink('s2', 's4', **http_link_config)
        self.addLink('s2', 's5', **http_link_config)
        self.addLink('s3', 's6', **http_link_config)
        self.addLink('s4', 's6', **http_link_config)
        self.addLink('s4', 's7', **http_link_config)
        self.addLink('s5', 's7', **http_link_config)

        # Add host links
        self.addLink('h1', 's1', **host_link_config)
        self.addLink('h2', 's1', **host_link_config)
        self.addLink('h3', 's2', **host_link_config)
        self.addLink('h4', 's2', **host_link_config)
        self.addLink('h5', 's6', **host_link_config)
        self.addLink('h6', 's6', **host_link_config)
        self.addLink('h7', 's7', **host_link_config)
        self.addLink('h8', 's7', **host_link_config)

        srv1 = self.addContainer("srv1", "h1", "dev_test", "bash", docker_args={})
        srv2 = self.addContainer("srv2", "h2", "dev_test", "bash", docker_args={})
        srv3 = self.addContainer("srv3", "h3", "dev_test", "bash", docker_args={})
        srv4 = self.addContainer("srv4", "h4", "echo_server", "python /home/server.py", docker_args={})
        srv5 = self.addContainer("srv5", "h5", "echo_server", "python /home/server.py", docker_args={})
        srv6 = self.addContainer("srv6", "h6", "echo_server", "python /home/server.py", docker_args={})

        #if not AUTOTEST_MODE:
            # Cannot spawn xterm for srv1 since BASH is not installed in the image:
            # echo_server.
            #spawnXtermDocker("srv2")
            #CLI(net)

        self.removeContainer("srv1")
        self.removeContainer("srv2")
        self.removeContainer("srv3")
        self.removeContainer("srv4")
        self.removeContainer("srv5")
        self.removeContainer("srv6")
        #net.stop()
        #mgr.stop()

topos = { 'fvtopo': ( lambda: FVTopo() ) }