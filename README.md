# Demo Appliance for Tanzu Community Edition

## Summary

A Virtual Appliance that pre-bundles all required dependencies to help customers in learning and deploying Tanzu Community Edition (TCE) clusters running on either VMware Cloud on AWS and/or vSphere 7.0+ environment for Proof of Concept, Demo and Dev/Test purposes.

This appliance will enable you to quickly go from zero to Kubernetes in less than 1hr with just an SSH client and a web browser!

## What's Included:
- Tanzu CLI
- Kubectl

## Good to know

- Once you select DHCP, the appliance will use the DHCP specified DNS server and ignore any values provided in the input field during deployment

## Known Issues

### Blank log output
When launching the installation process over the secure port, the log output in the Web browser is blank but the installation will continue in the background.  
Workaround: You can monitor the progress from the shell (for instance via SSH) by using journalctl -fl