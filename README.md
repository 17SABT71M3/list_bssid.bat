Sample output
```
32:73:72:66:59:45{1}
5d:49:69:6C:68:72{1}7d:48:51:41:66:4E{2}
41:6C:4E:54:54:54{1}
6f:42:53:75:58:74{1}
```
#### List WiFi Networks by BSSID only

> [!NOTE]
> + Automatically Sort by signal strength (stronger first)
> + Groups 'similar' BSSIDs together on the same line, according to the `netsh` output (`netsh` usually groups by same SSID. it also groups hidden networks together with exceptions, like when already connected to a network)
> + Sort by Signal strength does not apply to Grouped BSSIDs (only the first)
> + Might not list networks properly unless disconnected from current network(`netsh` behaviour)
