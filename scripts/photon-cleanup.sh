#!/bin/bash -eux
# Copyright 2019 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2
# cl: v0.12.1-dz-2022-06-13

##
## cleanup everything we can to make the OVA as small as possible
##

# Clear tdnf cache
echo '> Clearing tdnf cache...'
tdnf clean all


# Cleanup log files
echo '> Removing Log files...'
cat /dev/null > /var/log/wtmp 2>/dev/null
logrotate -f /etc/logrotate.conf 2>/dev/null
find /var/log -type f -delete
rm -rf /var/log/journal/*
rm -f /var/lib/dhcp/*

# Replacing the dd with fstrim
echo '> Zeroing device to make space...'
fstrim -v -a

echo '> Setting random root password...'
RANDOM_PASSWORD=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;)
echo "root:${RANDOM_PASSWORD}" | /usr/sbin/chpasswd

echo '> Clearing history ...'
unset HISTFILE && history -c && rm -fr /root/.bash_history

echo '> Done'
