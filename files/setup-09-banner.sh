#!/bin/bash
# Copyright 2020 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2

# Setup Login Banner

set -euo pipefail

echo -e "\e[92mCreating Login Banner ..." > /dev/console

cat > /etc/issue << EOF

Welcome to the Demo Appliance for Tanzu Community Edition (TCE)

EOF

/usr/sbin/agetty --reload
