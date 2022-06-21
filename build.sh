#!/bin/bash -x

echo "Building PhotonOS TCE Demo Appliance ..."
rm -f output-vmware-iso/*.ova

TCEVERSION=$(curl -s https://api.github.com/repos/vmware-tanzu/community-edition/releases/latest | sed -Ene '/^ *"tag_name": *"(v.+)",$/s//\1/p')

if [ $TCE_DEBUG_BUILD -ne 1 ]
then
echo "Applying packer build to photon.json ..."
packer build -var-file=photon-builder.json -var-file=photon-version.json -var="version=$TCEVERSION" photon.json
else
echo "Running packer build in DEBUG..."
PACKER_LOG=1 packer build -var-file=photon-builder.json -var-file=photon-version.json -var="version=$TCEVERSION" photon.json
fi