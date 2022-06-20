#!/bin/bash -eux
# Copyright 2020 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2
# cl: v0.12.1-dz-2022-06-13

##
## Enable Docker
##

cat > /etc/docker/daemon.json << __CUSTOMIZE_PHOTON__
{
  "ipv6": false
}
__CUSTOMIZE_PHOTON__

echo '> Enabling Docker...'
systemctl enable docker

reboot

echo '> Done'

