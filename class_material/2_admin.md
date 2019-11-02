# Moloch Admin Notes  

## User management  

Add admin  
```
/data/moloch/bin/moloch_add_user.sh admin "Admin User" AdminPassword --admin
```

Add user  
```
/data/moloch/bin/moloch_add_user.sh joeuser1 "Joe User" JoeUserPassword
/data/moloch/bin/moloch_add_user.sh joeuser2 "Joe User" JoeUserPassword
/data/moloch/bin/moloch_add_user.sh joeuser3 "Joe User" JoeUserPassword
/data/moloch/bin/moloch_add_user.sh joeuser4 "Joe User" JoeUserPassword
```


`./moloch_add_user.sh `
```
addUser.js [<config options>] <user id> <user friendly name> <password> [<options>]

Options:
  --admin               Has admin privileges
  --apionly             Can only use api, not web pages
  --email               Can do email searches
  --expression  <expr>  Forced user expression
  --remove              Can remove data (scrub, delete tags)
  --webauth             Can auth using the web auth header or password
  --webauthonly         Can auth using the web auth header only, password ignored
  --packetSearch        Can create a packet search job (hunt)
```

---
## Database (index) management  
General queries for status  
```
/data/moloch/db/db.pl http://localhost:9200 info
curl http://localhost:9200/_cat/health
```

Medium Reset Data (retain config and user accounts)  
```
sudo /data/moloch/db/db.pl localhost:9200 wipe
sudo rm -f /data/moloch/raw/*
```

Hard Reset Data to include user accounts  
```
sudo /data/moloch/db/db.pl localhost:9200 init
sudo rm -f /data/moloch/raw/*
```

Deleting a PCAP file will NOT delete the SPI (elastic) data.  
Deleting the SPI data will not delete the PCAP data from disk.  

Backups  
```
sudo /data/moloch/db/db.pl localhost:9200 backup
```
