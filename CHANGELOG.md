# CHANGELOG

## v0.12.1
- Initial Release based on the TKG demo appliance of @wlam
- Switched packer builder from VMware-ISO to vSphere-ISO per [suggestion](https://discuss.hashicorp.com/t/vmware-iso-vsphere-iso-with-questions/29851/2)
- Trimmed disk size to 20GB
- Disk type is now thin provisioned
- Disk Controller switched to NVMe
- Switched cleanup space reclamation from dd to fstrim per [suggestion](https://ext4.wiki.kernel.org/index.php/Ext4_VM_Images)
- Bumped vHW to 17 (ESXi 7 onwards)
- Switched base OS for the appliance to Photon OS version 4.0 Rev 2
- Switched to auto-download the latest version of kubectl by default
- Switched to ZSH theme to Powerline10k
- Auto-update appliance version from TCE release version (debatable if future proof)
- Switched to getOvfProperty.py to read OVF specs in the appliance and deprecated guest tool queries
- Removed IPv6 disable setting per [Photon docs](https://vmware.github.io/photon/docs/troubleshooting-guide/photon-os-general-troubleshooting/network-configuration/)
- Instead used LinkLocal=no on eth0 to avoid an IPv6 address
- Updated network config to explicitly deploy a DHCP config if no static IP is specified (TY Erik)
- Disabled IPv6 support for docker daemon
- Added Debug build option that includes the current Git Hash in the OVA name for cross-reference
- Switched VM Firmware to UEFI
- As an additional option: TCE installer UI is now fronted by an ENVOY reverse proxy with SSL to add minimal transport layer security
- Added option to enable the ENVOY admin interface via OVA property
- IPtables is no longer disabled/stopped by default but rather using default ACCEPT policies