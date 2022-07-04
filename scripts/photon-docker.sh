#!/bin/bash -eux
# Copyright 2020 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2
# Modified by Dominik Zorgnotti for TCE appliance

##
## Enable Docker
##


echo '> Enabling Docker...'
systemctl enable docker

reboot

echo '> Done'

