Sample output
```
N.A.
{1}32:73:72:66:59:45
{1}5d:49:69:6C:68:72{2}7d:48:51:41:66:4E
```
#### List WiFi Networks by BSSID only

> [!NOTE]
> + Automatically Sorts by signal strength (stronger first)
> + Groups 'similar' BSSIDs together on the same line, according to the `netsh` output (`netsh` usually groups by SSID or hidden networks but there could be exceptions)
> + Sort by Signal strength does not apply to Grouped BSSIDs (only the first)
> + Might not list properly unless disconnected (`netsh` behaviour)
