# Analyze PCAP with Moloch  

Borrowed heavily from: https://molo.ch/  

---
## Sessions Page  
The Sessions page displays a list of indexed sessions for the selected time period and search expression. It includes a timeline graph and map of the session results.  
- Search: The search bar allows for powerful search queries to narrow down the data. Click the owl for available fields.  
- Session detail: Get more information about any session and view the session's packet data by clicking the "+" button.  
- Value actions: Hover and click any value to view a dropdown menu of actions, like applying that value as search criteria.  
- Export PCAP: You can export search results as PCAP or CSV by clicking the "Actions" () drop down menu on the top right.  
- Timeline search: Click and drag an area in the timeline to filter sessions by time.  
- Country search: Click a country on the map to apply it as search criteria.  

#### Example search expressions  
Similar to wireshark format  

```
port.src == 123
port.dst == 53
```

Can be chained  
```
port.dst == 53 && packets == 1
```

Supports wildcards  
```
ip.src == 66.110.57.97 && http.user-agent == *Nikto*
ip.dst == 192.0.78.195 && http.uri == *coin* && ip.src == 172.17.11.222
```

Suricata alert based searches  
```
suricata.signature == "ET POLICY Vulnerable Java Version 1.7.x Detected"
```

SMTP Parsing  
```
protocols  == smtp && email.subject == "*CRITICAL*"
```

---
## SPI View Page  
The SPI (Session Profile Information) View page allows you to view unique values with session counts for each of the captured fields.  
- Toggle categories: Click on any section to open or close any field category.  
- Search for fields: Search for fields within a category by using the input box within a category.  
- Toggle fields: Click on a field in the top section of a category to toggle the field's visibility. You can also click the load/unload all buttons to load/unload all the fields in that category.  
- Cancel Load: Click the cancel button on the top right of the page if the page is taking a long time load data or you made a mistake when you issued a query.  

---
## SPI Graph Page  
The SPI (Session Profile Information) Graph page shows a temporal view for the top unique values of any field.  
- Total: The first timeline graph and map shows an aggregation of all the results below. Click on the "x" button on this map to hide all maps.  
- Search for fields: Make a selection from the SPI Graph drop down on the top left to view the unique values for different fields.  
- More fields: Change the number of Max Elements to display more results.  
- Sorting: Change the sort by dropdown to change how the results are sorted. By default, the results are sorted starting with the highest unique field value.  

---
## Connections Page  
The Connections page shows a network graph of your search results.  
- Lock: Click and drag a node to lock it into place in the graph.  
- Node Info: Hover over a node or a link to view more information (or hide it).  
- Node/Link Weight: Change the Node/Link Weight dropdown to change how the node and link sizes are calculated.
- Change Source/Destination Nodes: Make a selection from the Src and Dst drop downs to visualize your data based upon different captured field relationships  


## Demo 1.pcap  
Source: DEFCON27 Blueteam CTF  
- Start with session > all timespan  
- Move to SPIView > note limitation on 'all' range  
- Back to session and select range  
- Go to connectons > observe relationships  
- Increase query size  
