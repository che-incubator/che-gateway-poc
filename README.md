# Eclipse Che single-host POC with HAProxy

## HOWTO
 - have Openshift cluster running and `oc` working
 - go to POC folder
 - `sh 01_cheOS.sh` will create namespace with "Che" and `che-gateway` pods. Script will print the url at the end.
 - `sh 02_addWorkspace.sh` will create a "workspace" with random name and reconfigure haproxy with everything needed to live reload the config. It will print the urls of all existing workspaces at the end of the script.
