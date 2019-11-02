# Troubleshooting Moloch  

## Verify services:  
```
systemctl status moloch*
systemctl status elastic*

systemctl status elasticsearch moloch* | grep "Active:" -B 2 | GREP_COLOR='1;32' grep --color=always "running\|$"

watch -d 'systemctl status elasticsearch moloch* | grep "Active:" -B 2'
```

## Restart services:  
```
sudo systemctl restart molochcapture.service
sudo systemctl restart molochviewer.service
sudo systemctl restart elasticsearch.service
```

## Review logs and data:  
```
tailf /var/log/messages
tailf /data/moloch/logs/capture.log
tailf /data/moloch/logs/viewer.log

sudo watch -d 'ls -lah /data/moloch/raw/'
```

## Modify config if needed:
```
vim /data/moloch/etc/config.ini
```

## Elastic  
```
curl http://localhost:9200/_cluster/state?pretty
curl http://localhost:9200/_cluster/health?pretty
curl http://localhost:9200/_cluster/stats?pretty
```

---
## Capture service failing  
Dummy interface guide  
https://unix.stackexchange.com/questions/152331/how-can-i-create-a-virtual-ethernet-interface-on-a-machine-without-a-physical-ad  

### Moloch Script  
```
sudo /data/moloch/bin/moloch_config_interfaces.sh
```
```shell
#!/bin/sh
for interface in ens37; do
  /sbin/ethtool -G $interface rx 4096 tx 4096 || true
  for i in rx tx sg tso ufo gso gro lro; do
      /sbin/ethtool -K $interface $i off || true
  done
done
```

### Alternate Method  
Inspired by https://github.com/rocknsm/rock  
Also helpful https://gist.github.com/PSJoshi/981730e4315629c60f81347010549468  

`sudo vim /etc/sysconfig/network-scripts/ifcfg-ens37`  
```
DEVICE=ens37
NAME=ens37
TYPE=Ethernet
BOOTPROTO=none
IPV4_FAILURE_FATAL=no
IPV6INIT=no
IPV6_FAILURE_FATAL=no
ONBOOT=yes
NM_CONTROLLED=no
PROMISC=yes
```


`sudo vim /sbin/ifup-local`  
```shell
#!/bin/bash
# File: /sbin/ifup-local
#
#
# This script is run after normal sysconfig network-script configuration
# is performed on RHEL/CentOS-based systems.
#
# Parameters:
# $1: network interface name
#
# Post ifup configuration for tuning capture interfaces
# This is compatible with the ixgbe driver, YMMV

# Change this to something like /tmp/ifup-local.log for troubleshooting
LOG=/dev/null
#LOG=/tmp/ifup-local.log

case $1 in
ens37)

  for i in rx tx sg tso ufo gso gro lro rxvlan txvlan
  do
    ethtool -K $1 $i off &>$LOG
  done

  ethtool -N $1 rx-flow-hash udp4 sdfn  &>$LOG
  ethtool -N $1 rx-flow-hash udp6 sdfn &>$LOG
  ethtool -n $1 rx-flow-hash udp6 &>$LOG
  ethtool -n $1 rx-flow-hash udp4 &>$LOG
  ethtool -C $1 rx-usecs 10 &>$LOG
  ethtool -C $1 adaptive-rx off &>$LOG
  ethtool -G $1 rx 4096 &>$LOG

  # Disable ipv6
  echo 1 > /proc/sys/net/ipv6/conf/$1/disable_ipv6 &>$LOG
  echo 0 > /proc/sys/net/ipv6/conf/$1/autoconf &>$LOG

  # Set promiscuous mode
  ip link set $1 promisc on &>$LOG

  # Just in case ipv6 is already on this interfaces, let's kill it
  ip addr show dev $1 | grep --silent inet6

  if [ $? -eq 0 ]
  then
    ADDR=$(ip addr show dev $1 | grep inet6 | awk '{ print $2 }')
    ip addr del $ADDR dev $1 &>$LOG
  fi

;;

*)
# No post commands needed for this interface
;;

esac
```
Mod permissions and execute  
```
sudo chmod 755 /sbin/ifup-local
sudo /sbin/ifup-local ens37
sudo ifdown ens37
sudo ifup ens37
```

### Before
`ip a`  
```
ens37: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
link/ether 00:0c:29:b8:60:bf brd ff:ff:ff:ff:ff:ff
```

`ifconfig ens37`  
```
ens37: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
    ether 00:0c:29:b8:60:bf  txqueuelen 1000  (Ethernet)
    RX packets 0  bytes 0 (0.0 B)
    RX errors 0  dropped 0  overruns 0  frame 0
    TX packets 354  bytes 58476 (57.1 KiB)
    TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```  

### After  
```
ens37: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:0c:29:b8:60:bf brd ff:ff:ff:ff:ff:ff
```

`ifconfig ens37`  
```
ens37: flags=4419<UP,BROADCAST,RUNNING,PROMISC,MULTICAST>  mtu 1500
        ether 00:0c:29:b8:60:bf  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 357  bytes 58786 (57.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
Now we should have promiscuous mode for capture  

Check for additional features to disable  
Disable as need
```
ethtool -k ens37 | grep -v fixed | grep ": on"

sudo ifdown ens37
sudo ethtool -K ens37 tx off sg off gro off gso off lro off tso off
sudo ifup ens37
```


---
