#!/bin/bash
# Copyright 2019 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

# OS Specific Settings where ordering does not matter

set -euo pipefail

# Enable SSH
systemctl enable sshd
systemctl start sshd

# Ensure docker is stopped to allow config of network/proxies
systemctl stop docker

echo -e "\e[92mConfiguring OS Root password ..." > /dev/console
echo "root:${ROOT_PASSWORD}" | /usr/sbin/chpasswd

echo -e "\e[92mConfiguring Docker Network ..." > /dev/console
if [ "${DOCKER_NETWORK_CIDR}" != "172.17.0.1/16" ]; then
    cat > /etc/docker/daemon.json << __CUSTOMIZE_PHOTON__
{
    "bip": "${DOCKER_NETWORK_CIDR}",
    "ipv6": false,
    "log-opts": {
       "max-size": "10m",
       "max-file": "5"
    }
}
__CUSTOMIZE_PHOTON__
else
    cat > /etc/docker/daemon.json << __CUSTOMIZE_PHOTON__
{
    "ipv6": false,
    "log-opts": {
       "max-size": "10m",
       "max-file": "5"
    }
}
__CUSTOMIZE_PHOTON__
fi
# Restart docker
echo -e "\e[92mRestarting Docker ..." > /dev/console
systemctl restart docker
