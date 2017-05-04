# Exporting Edge Gateway configs from NSX Manager and Importing into vCloud Director 

## These Scripts export NAT and Firewall Configs from NSX Manager, change/format the output to be compatible with vCloud Director, then imports said config into vCloud Director. 
I have run into several situations where an Edge Gateway (vShield Edge/vSE/Edge/whatever you want to call it) is unmanageable in vCloud Director, but still running and functioning properly. For different reasons the Edge's config in vCloud becomes corrupted/incomplete and performing a redeploy would cause a lose of configuration. Specifically Firewall and NAT rules. 

These scripts will pull the Firewall and NAT rules from NSX Manager on the back end, where the config is complete/correct and import it into vCloud Director, allowing for a redeploy to take place without losing client infromatiuon.

