# Demo Appliance for Tanzu Community Edition

## Summary

This project provides a VMware Virtual Appliance that pre-bundles all required dependencies for deploying Tanzu Community Edition (TCE) clusters.

### Out Of Scope
The virtual appliance cannot provide the general requirements for the target platform (infrastructure provider).
For example, to deploy a Management Cluster to vSphere you are required to meet the prerequisits lik an appropriate network setup wie DHCP.

### Download

The latest release is [v0.12.1](https://github.com/dominikzorgnotti/tce-demo-appliance/releases/tag/v0.12.1)

### Alternatives

After publishing this project I learned about the [OVA Appliance for Tanzu Community Edition](https://github.com/guarddog-dev/VMware_Photon_OVA) from [Russell Hamker](https://twitter.com/butch7903). It’s another amazing project, make sure to give it a spin as well.

## vSphere Workflow Example

I walked through a deployment example, with screenshots, on my [blog](https://why-did-it.fail/blog/2022-03-tce-demo-appliance/).

### Steps
1. Read the "Before you begin" section of the [documentation](https://tanzucommunityedition.io/docs/v0.12/vsphere/)
2. Prepare your vSphere environment as described
  - If you want to use a service account, you can use [this gist to automate the task with govc](https://gist.github.com/dominikzorgnotti/cf2264945c9316eaa25f196d41eda308)
3. You should keep in mind that any reference to the "local bootstrap machine" in the documentation is now meant for your virtual appliance.
4. Deploy the appliance, either locally with fusion/workstation or on vSphere.
5. Power on the virtual appliance and wait for the customization process to finish.
5. After the deployment finished you can open the installer UI to the port you specified during the installation.
  - The default is <appliance_ip>:5555 for http and <appliance_ip>:5556 for https

## Good To Know

- The installer will continue to run for approximately two minutes after the initial deployment of the appliance. The appliance is ready after the log entry "reverse proxy activiation".
- When you select leave the IP address empty, the appliance will default to DHCP network configuration.
- When you use DHCP network configuration, the DNS server input field will be ignored. The appliance will use the DNS server supplied by DHCP.
- The tanzu installer process will exit once you successfuly create a cluster.
  - You need to restart the tanzu-bootstrap.service on the appliance or reboot the appliance if you want to deploy another cluster.
- You need to increase the appliance CPU and memory to the [required minimums per documentation](https://tanzucommunityedition.io/docs/v0.12/docker-install-mgmt/) if you want to deploy a cluster local to the appliance with Docker.
 

## Known Issues

### Blank Log Output In the UI With HTTPS
When you launch the installation process over https/the secure port, the log output in the Web browser is blank.
Cause: The logs are streamed using [Gorilla WebSocket](https://github.com/gorilla/websocket) which has multiple issues when accessed with [https](https://github.com/gorilla/websocket/pull/740). 
Workaround: The installation continues in the background. You can monitor the progress from the shell (for instance via SSH) by using journalctl -fl, follow the logs /var/log/tanzu-ce.log or use the non-secure port to view the output.

### HTTPS connection warning
When you access the UI over https you will see a chrome security error and no button to proceed from here.
Cause: The page fails to pass the HTTP Strict Transport Security (HSTS) policy.
Workaround: You can type "thisisunsafe" in Chrome to ignore the error.

### No Supported Hardware Versions Among Vmx-17
When you attempt to deploy the aplliance an error is shown "Issues detected with selected template: <...> No supported hardware ...".
Cause: The appliance uses a virtual hardware version that requires a version that is compatible with vSphere 7 and later.
Workaround: None. vSphere 6 is going out of general support soon.


## Credits
- William Lam for supporting me here with his framework for the TKG Demo Appliance
- Erik Boettcher for running the first tests in his labs and calling out a set of bugs
