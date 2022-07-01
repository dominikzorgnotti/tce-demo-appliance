# Demo Appliance for Tanzu Community Edition

## Summary

A Virtual Appliance that pre-bundles all required dependencies for deploying Tanzu Community Edition (TCE) clusters.

## What's Included:
- Tanzu CLI
- Kubectl

## Workflow (vSphere example)

### What is not covered
The appliance cannot provide the specific prerequisites in your target environment (vSphere, AWS, GCP, ...). For instance to deploy a Management Cluster to vSphere, you are still required to provide a network with DHCP server and upload the OVF images and covert them to a template.

### Steps
- Read through the "Before you begin" section of the [documentation](https://tanzucommunityedition.io/docs/v0.12/vsphere/).
- Prepare your vSphere environment as described (upload templates, create networks and accounts, ...)
  -[Service Account requirements for vSphere](https://tanzucommunityedition.io/docs/v0.12/ref-vsphere/) or use [this gist to automate the task with govc](https://gist.github.com/dominikzorgnotti/cf2264945c9316eaa25f196d41eda308)
  - Get the [vSphere templates](https://tanzucommunityedition.io/docs/v0.12/getting-started/) from myVMware/Customer Connect
- From a networking (and firewall/security) perspective, please keep in mind that any reference to the "local bootstrap machine" is now meant for your TCE demo appliance
- Deploy the appliance, either locally with fusion/workstation or on vSphere
- Point your web browser to the installer port, default is <appliance_ip>:5555 for http and <appliance_ip>:5556 for https


## Good to know

- After the initial deployment of the appliance, the installer will continue to run for one or two minutes. After the reverse proxy activiation the appliance is ready.
- Once you select DHCP, the appliance will use the DHCP specified DNS server and ignore any values provided in the input field during deployment
- When you deploy a succesfully deploy a cluster, the tanzu installer process with exit. If you want to deploy another cluster, you need to restart the tanzu-bootstrap.service on the appliance or reboot the appliance.
- When you want to deploy a cluster to docker locally, you need to increase the appliance CPU and memory to the required minimums per documentation
- Deployment target is vSphere 7 onwards, with vSphere 6 going EOGS in less than six months I set the vHW accordingly
 

## Known Issues

### Blank log output
When launching the installation process over the secure port, the log output in the Web browser is blank but the installation will continue in the background.
Cause: The logs are shown using websockets which currently does not work when being tunneled through https  
Workaround: You can monitor the progress from the shell (for instance via SSH) by using journalctl -fl or use the non-secure port to view the output.

### Proxy Support not tested
Proxy Support has not been tested yet

## Credits
- William Lam for supporting me here with his framework for the TKG Demo Appliance
- Erik Boettcher for running the first tests in his labs and calling out a set of bugs