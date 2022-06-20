#!/bin/bash -x

echo "Building PhotonOS TCE Demo Appliance ..."
rm -f output-vmware-iso/*.ova

echo "Applying packer build to photon.json ..."
VERSION=$(curl -s https://api.github.com/repos/vmware-tanzu/community-edition/releases/latest | sed -Ene '/^ *"tag_name": *"(v.+)",$/s//\1/p')
PACKER_LOG=1 packer build -var-file=photon-builder.json -var-file=photon-version.json -var="version=$VERSION" photon.json
