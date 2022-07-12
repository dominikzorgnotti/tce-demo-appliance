/*
This is the packer HCL2 variable file for the Tanzu Community Edition (TCE) demo appliance
GitHub Repo: https://github.com/vmware-tanzu/community-edition

Modify the values as needed.
https://www.packer.io/docs/templates/hcl_templates/variables#type-constraints for more info on the packer variable types.
To quote: If both the type and default arguments are specified, the given default value must be convertible to the specified type.
By design the type is explicitly added to show the intended usage/values for a variable.
*/

# These variables holds the TCE version information as well as git commit infos
variable "version" {
  type        = string
  description = "The release of Tanzu Community Edition"
}

variable "gitcommit" {
  type        = string
  description = "The git hash of Tanzu Community Edition demo appliance repository"
}

# These variables are used by packer to create the template (VM) in a given target vCenter
variable "builder_http" {
  type        = string
  description = "The preferred IP/FQDN packer should use to launch the web service for kickstart."
  default     = "172.20.2.43"
}

variable "builder_vcenter" {
  type        = string
  description = "The IP/FQDN packer of the vCenter where packer should create the VM."
  default     = "cube-vcsa-01.lab.why-did-it.fail"
}

variable "builder_vcenter_username" {
  type        = string
  description = "The username for packer to connect to the vCenter. Ensure sufficient permissions."
  default     = "svc_packer@vsphere.local"
}

variable "builder_vcenter_password" {
  type        = string
  description = "The password for packer to connect to the vCenter."
  default     = "tceDEMO01!"
  sensitive   = true
}

variable "builder_vcenter_cluster" {
  type        = string
  description = "The vSphere cluster where packer should create the VM. Enable DRS for initial placement."
  default     = "cl-cube-01"
}

variable "builder_vcenter_datastore" {
  type        = string
  description = "The datastore where packer should create the VM."
  default     = "ds-cubevsan-01"
}

variable "builder_vcenter_portgroup" {
  type        = string
  description = "The network/portgroup to which packer should attach the VM. Make sure you have a running DHCP service."
  default     = "pg-dvs-01-vlan201-172_20_1_0_24-dhcp"
}

# This is the base operating system used for the appliance. Currently Photon OS 4 Rev 2.
variable "iso_url" {
  type        = string
  description = "A URL to the ISO file of the operating system used to build the image."
  default     = "https://packages.vmware.com/photon/4.0/Rev2/iso/photon-4.0-c001795b8.iso"
}

variable "iso_checksum" {
  type        = string
  description = "The checksum for the ISO file. Required by packer"
  default     = "5af288017d0d1198dd6bd02ad40120eb"
}

# These variables defines the Virtual Machine built by packer
variable "vm_name" {
  type        = string
  description = "The name of the virtual machine created by packer"
  default     = "TCE-Demo-Appliance"
}

variable "description" {
  type        = string
  description = "The description set to the virtual machine created by packer"
  default     = "Demo Appliance for Tanzu Kubernetes Community Edition (TCE)"
}

variable "numvcpus" {
  type        = number
  description = "The number of vCPU for the virtual machine created by packer"
  default     = 2
}

variable "ramsize" {
  type        = number
  description = "The amount of RAM for the virtual machine created by packer"
  default     = 8096
}

# These variables are used by the ovftool PowerCLI script (unregister_vm.ps1) to create the OVA file
variable "guest_username" {
  type        = string
  description = "The username for packer to connect to the vVirtual Machine."
  default     = "root"
}

variable "guest_password" {
  type        = string
  description = "The password used by packer to connect to the Virtual Machine."
  default     = "tceDEMO01!"
  sensitive   = true
}

# These variables are used by the ovftool PowerCLI script (unregister_vm.ps1) to create the OVA file
variable "ovftool_deploy_vcenter" {
  type    = string
  description = "The IP/FQDN packer of the vCenter where packer created the Artifact."
  default = "cube-vcsa-01.lab.why-did-it.fail"
}

variable "ovftool_deploy_vcenter_password" {
  type    = string
  description = "The username for packer to connect to the vCenter. Ensure sufficient permissions."
  default = "tceDEMO01!"
  sensitive   = true
}

variable "ovftool_deploy_vcenter_username" {
  type    = string
  description = "The password for packer to connect to the vCenter."
  default = "svc_packer@vsphere.local"
}

variable "photon_ovf_template" {
  type    = string
  description = "The XML file with the user-definied OVF properties for this appliance."
  default = "photon.xml.template"
}