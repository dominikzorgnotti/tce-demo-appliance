# Demo Appliance for Tanzu Community Edition

## Summary

A Virtual Appliance that pre-bundles all required dependencies to help customers in learning and deploying Tanzu Community Edition (TCE) clusters running on either VMware Cloud on AWS and/or vSphere 7.0+ environment for Proof of Concept, Demo and Dev/Test purposes.

This appliance will enable you to quickly go from zero to Kubernetes in less than 1hr with just an SSH client and a web browser!

## What's Included:
- Tanzu CLI
- Kubectl

## Workflow (vSphere example)

### What is not covered
The appliance cannot provide the specific prerequisites in your target environment (vSphere, AWS, GCP, ...). For instance to deploy a Management Cluster to vSphere, you are still required to provide a network with DHCP server and upload the OVF images and covert them to a template.

### Steps
- Read through the "Before you begin" section of the [documentation](https://tanzucommunityedition.io/docs/v0.12/vsphere/).
- Prepare your vSphere environment as described (upload templates, create networks and accounts, ...)
- From a networking (and firewall/security) perspective, please keep in mind that any reference to the "local bootstrap machine" is now meant for your TCE demo appliance
- Deploy the appliance, either locally with fusion/workstation or on vSphere
- Point your web browser to the installer port, default is <appliance_ip>:5555 for http and <appliance_ip>:5556


## Good to know

- After the initial deployment of the appliance, the installer will continue to run for one or two minutes. After the reverse proxy activiation the appliance is ready.
- Once you select DHCP, the appliance will use the DHCP specified DNS server and ignore any values provided in the input field during deployment
- When you deploy a succesfully deploy a cluster, the tanzu installer process with exit. If you want to deploy another cluster, you need to restart the service on the appliance or reboot the appliance.

## Known Issues

### Blank log output
When launching the installation process over the secure port, the log output in the Web browser is blank but the installation will continue in the background.
Cause: The logs are shown using websockets which currently does not work when being tunneled through https  
Workaround: You can monitor the progress from the shell (for instance via SSH) by using journalctl -fl or use the non-secure port to view the output.

