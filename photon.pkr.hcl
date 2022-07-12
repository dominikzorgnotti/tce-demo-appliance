# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# See https://www.packer.io/docs/templates/hcl_templates/blocks/packer for more info
packer {
  required_version = ">= 1.8.0"
  required_plugins {
    vsphere = {
      version = ">= v1.0.6"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
source "vsphere-iso" "autogenerated_1" {
  CPUs                 = var.numvcpus
  RAM                  = var.ramsize
  boot_command         = ["<esc><wait>c", "linux /isolinux/vmlinuz root=/dev/ram0 loglevel=3 insecure_installation=1 ks=http://${var.builder_http}:{{ .HTTPPort }}/photon-kickstart.json photon.media=cdrom", "<enter>", "initrd /isolinux/initrd.img", "<enter>", "boot", "<enter>"]
  boot_order           = "disk,cdrom"
  boot_wait            = "2s"
  cdrom_type           = "sata"
  cluster              = var.builder_vcenter_cluster
  datastore            = var.builder_vcenter_datastore
  disk_controller_type = ["nvme"]
  export {
    force            = true
    options          = ["extraconfig"]
    output_directory = "./output-vsphere-iso"
  }
  firmware            = "efi"
  guest_os_type       = "vmwarePhoton64Guest"
  http_directory      = "http"
  insecure_connection = true
  iso_checksum        = var.iso_checksum
  iso_url             = var.iso_url
  network_adapters {
    network      = var.builder_vcenter_portgroup
    network_card = "vmxnet3"
  }
  notes            = "Appliance serving Tanzu Community Edition version: ${var.version}"
  password         = var.builder_vcenter_password
  shutdown_command = "/sbin/shutdown -h now"
  shutdown_timeout = "1000s"
  ssh_password     = var.guest_password
  ssh_port         = 22
  ssh_username     = var.guest_username
  storage {
    disk_size             = "20480"
    disk_thin_provisioned = true
  }
  username       = var.builder_vcenter_username
  vcenter_server = var.builder_vcenter
  vm_name        = var.vm_name
  vm_version     = 17
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.vsphere-iso.autogenerated_1"]

  provisioner "shell" {
    scripts = ["scripts/photon-settings.sh"]
  }

  provisioner "shell" {
    expect_disconnect = true
    scripts           = ["scripts/photon-docker.sh"]
  }

  provisioner "shell" {
    pause_before = "20s"
    scripts      = ["scripts/photon-cleanup.sh"]
  }

  provisioner "file" {
    destination = "/root/setup/getOvfProperty.py"
    source      = "files/getOvfProperty.py"
  }

  provisioner "file" {
    destination = "/etc/rc.d/rc.local"
    source      = "files/rc.local"
  }

  provisioner "file" {
    destination = "/root/setup/setup.sh"
    source      = "files/setup.sh"
  }

  provisioner "file" {
    destination = "/root/setup/setup-01-os.sh"
    source      = "files/setup-01-os.sh"
  }

  provisioner "file" {
    destination = "/root/setup/setup-02-proxy.sh"
    source      = "files/setup-02-proxy.sh"
  }

  provisioner "file" {
    destination = "/root/setup/setup-03-network.sh"
    source      = "files/setup-03-network.sh"
  }

  provisioner "file" {
    destination = "/root/setup/setup-04-tce-prereqs.sh"
    source      = "files/setup-04-tce-prereqs.sh"
  }

  provisioner "file" {
    destination = "/root/setup/setup-05-shell.sh"
    source      = "files/setup-05-shell.sh"
  }

  provisioner "file" {
    destination = "/root/setup/setup-09-banner.sh"
    source      = "files/setup-09-banner.sh"
  }

  provisioner "file" {
    destination = "/root/.p10k.zsh"
    source      = "files/p10k.zsh"
  }

  provisioner "file" {
    destination = "/etc/motd"
    source      = "files/motd"
  }

  post-processor "shell-local" {
    environment_vars = ["PHOTON_VERSION=${var.version}", "PHOTON_APPLIANCE_NAME=${var.vm_name}", "FINAL_PHOTON_APPLIANCE_NAME=${var.vm_name}-${var.version}${var.gitcommit}", "PHOTON_OVF_TEMPLATE=${var.photon_ovf_template}"]
    inline           = ["cd manual", "./add_ovf_properties.sh"]
  }
  post-processor "shell-local" {
    inline = ["pwsh -F unregister_vm.ps1 ${var.ovftool_deploy_vcenter} ${var.ovftool_deploy_vcenter_username} ${var.ovftool_deploy_vcenter_password} ${var.vm_name}"]
  }
}