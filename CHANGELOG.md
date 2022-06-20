# CHANGELOG

## v0.12.1
- Initial Release based on the TKG demo appliance of @wlam
- Switched build process to packer vSphere-ISO builder per [suggestion](https://discuss.hashicorp.com/t/vmware-iso-vsphere-iso-with-questions/29851/2)
- Trimmed disk size to 15GB
- Switched base OS for the appliance to Photon OS version 4.0 Rev 2
- Switched to auto-download the latest version of kubectl by default
- Switched to ZSH theme to Powerline10k
- Auto-update appliance version from TCE release version (debatable if future proof)
- Switched to getOvfProperty.py to read OVF specs in the appliance and deprecated guest tool queries
- Removed IPv6 disable setting per Photon docs (https://vmware.github.io/photon/docs/troubleshooting-guide/photon-os-general-troubleshooting/network-configuration/)
- Instead used LinkLocal=no on eth0 to avoid an IPv6 address
- Disabled IPv6 support for docker daemon