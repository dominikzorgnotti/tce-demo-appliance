#!/bin/bash -x

echo "Building PhotonOS TCE Demo Appliance ..."
rm -f output-vmware-iso/*.ova

TCEVERSION=$(curl -s https://api.github.com/repos/vmware-tanzu/community-edition/releases/latest | sed -Ene '/^ *"tag_name": *"(v.+)",$/s//\1/p')
GIT_COMMIT="-$(git show --format="%h" --no-patch)"

packer init .
PACKER_LOG=1 packer build -var "version=$TCEVERSION" -var "gitcommit=$GIT_COMMIT" .
