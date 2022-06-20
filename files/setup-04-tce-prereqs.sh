#!/bin/bash
# Copyright 2019 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2
# cl: v0.12.1-dz-2022-06-13


# Setup Docker and TCE pre-reqs

set -euo pipefail

echo -e "\e[92mStarting Docker ..." > /dev/console
systemctl daemon-reload
systemctl start docker.service
systemctl enable docker.service

echo -e "\e[92mDisabling/Stopping IP Tables  ..." > /dev/console
systemctl stop iptables
systemctl disable iptables

echo '\e[92mSwitching Working Directory...' > /dev/console
cd /root/setup

echo '\e[92mSetup Tanzu CLI ...' > /dev/console
TANZU_CLI_LATEST=$(curl -s https://api.github.com/repos/vmware-tanzu/community-edition/releases/latest | sed -Ene '/^ *"tag_name": *"(v.+)",$/s//\1/p')
export ALLOW_INSTALL_AS_ROOT=true
# Ran into "./install.sh: line 44: HOME: unbound variable", need to override HOME var 
export HOME="/root"
curl -H "Accept: application/vnd.github.v3.raw" -L https://api.github.com/repos/vmware-tanzu/community-edition/contents/hack/get-tce-release.sh -o get-tce-release.sh
chmod a+x get-tce-release.sh
./get-tce-release.sh $TANZU_CLI_LATEST linux
tar xzvf tce-linux-amd64-${TANZU_CLI_LATEST}.tar.gz
cd tce-linux-amd64-${TANZU_CLI_LATEST}
./install.sh


echo '\e[92mCreating TCE installer service...' > /dev/console
cat > /etc/systemd/system/tanzu-bootstrap.service << __CUSTOMIZE_PHOTON__
[Unit]
Description=Systemd Service to run the Tanzu installer interface to deploy a management cluster
After=syslog.target network.target auditd.service systemd-journald.socket basic.target system.slice

[Service]
Type=idle
Environment="HOME=/root"
Restart=on-failure
ExecStart=/usr/local/bin/tanzu management-cluster create --ui --bind 0.0.0.0:${TANZU_INSTALLER_PORT} --browser none

[Install]
WantedBy=multi-user.target
__CUSTOMIZE_PHOTON__

echo '\e[92mActivating TCE installer service...' > /dev/console
systemctl daemon-reload
systemctl enable tanzu-bootstrap.service
sleep 15
systemctl start tanzu-bootstrap.service



# End of Script
