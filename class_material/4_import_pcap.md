# Importing PCAP to Moloch  

## Obtain Pcaps  
```
wget https://s3.amazonaws.com/tcpreplay-pcap-files/smallFlows.pcap
wget https://s3.amazonaws.com/tcpreplay-pcap-files/bigFlows.pcap

```

## Try in Wireshark  
```
wireshark ./smallFlows.pcap &
wireshark ./bigFlows.pcap &

```

## Moloch listening on dummy interface ens37 (for this class)  
```
sudo tcpreplay -i ens37 smallFlows.pcap
sudo tcpreplay -i ens37 bigFlows.pcap
```

## Optional: Monitor moloch directory  
View pcaps being written  
```
sudo watch -d 'ls -lah /data/moloch/raw/'
```

## Tune for speed  
```
sudo tcpreplay --preload-pcap --topspeed -i ens37 smallFlows.pcap
sudo tcpreplay --preload-pcap --topspeed -i ens37 bigFlows.pcap
```

---
## Via moloch  
Read a single file in:  
```
sudo /data/moloch/bin/moloch-capture -pcapfile smallFlows.pcap
```

Can also specify a unique config file  
To process yara rules, alternate interface, bpf filters, output dir...
```
sudo /data/moloch/bin/moloch-capture -config /data/moloch/etc/alt_config.ini -pcapfile smallFlows.pcap
```

Read all files in a directory:  
```
sudo /data/moloch/bin/moloch-capture -pcapdir /tmp/ctf_caps
```

Note the timestamps with this method  
Expand your search to 'All'  
http://localhost:8005/sessions?graphType=lpHisto&seriesType=bars&stopTime=1295981908&startTime=1295981446  

Depending on your use case, this may be required as opposed to tcpreplay  

## Via moloch offline monitored  
```
mkdir /tmp/ctf_caps
sudo systemctl stop molochcapture.service
sudo /data/moloch/bin/moloch-capture --monitor --pcapdir /tmp/ctf_caps
```
In a separate terminal:  
```
cp smallFlows.pcap /tmp/ctf_caps/
```
