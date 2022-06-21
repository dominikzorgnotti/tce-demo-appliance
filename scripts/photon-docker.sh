#!/bin/bash -eux
# Copyright 2020 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2
# cl: v0.12.1-dz-2022-06-13

##
## Enable Docker
##


echo '> Enabling Docker...'
systemctl enable docker

reboot

echo '> Done'

