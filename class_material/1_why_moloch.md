# What is Moloch?  
Free.  
Full Packet Capture parsing tool.  
Fast searching with elastic and SPI metadata.  
Able to search across multiple pcaps and export/recompile easily.  
Solid user interface.  
Supported. Andy Wick is very active on development and their slack channel.  

## IDS  
Doesn't really do that.  
But do you really need it to? We have enough inline solutions.  

## A wireshark replacement?  
Not entirely.  
But it augments network protocol analyzers well.  

## Scales well  
https://molo.ch/architecture  

Single host deployment  
- Hasty analysis  
- Stand alone "offline" analyzer  
- CTF tool  

Multiple host/cluster deployment  
- Capture multiple network segments  
- Distributed elastic searches  
- Multiple viewers  
- Shared WISE server  
- Can incorporate a packet broker for high traffic  
- Disk IO speed is your limiting factor  

## Other interesting capabilities  
Remote capture  
- Stream pcap via ssh over a named pipe  

WISE (With Intelligence See Everything)  
- Enhance your SPI data in moloch  
- Integrations with zeek/bro, alien vault, splunk for example  

PCAP encryption  
- PCAP at rest encryption  
- aes-256 supported  

Able to integrate suricata alerts to sessions  
```
# Add suricata.so to your plugins line, or add a new plugins line
plugins=suricata.so
# suricataAlertFile should be the full path to your alert.json or eve.json file
suricataAlertFile=/nids/suricata/eve.json
```  

Did we mention it is free?  
