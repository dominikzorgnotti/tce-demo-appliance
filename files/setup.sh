#!/bin/bash
# Copyright 2020 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2
# cl: v0.12.1-dz-2022-06-13

set -euo pipefail

# Extract all OVF Properties
APPLIANCE_DEBUG=$(/root/setup/getOvfProperty.py "guestinfo.debug")
HOSTNAME=$(/root/setup/getOvfProperty.py "guestinfo.hostname")
IP_ADDRESS=$(/root/setup/getOvfProperty.py "guestinfo.ipaddress")
NETMASK=$(/root/setup/getOvfProperty.py "guestinfo.netmask" | awk -F ' ' '{print $1}')
GATEWAY=$(/root/setup/getOvfProperty.py "guestinfo.gateway")
DNS_SERVER=$(/root/setup/getOvfProperty.py "guestinfo.dns")
DNS_DOMAIN=$(/root/setup/getOvfProperty.py "guestinfo.domain")
NTP_SERVER=$(/root/setup/getOvfProperty.py "guestinfo.ntp")
HTTP_PROXY=$(/root/setup/getOvfProperty.py "guestinfo.http_proxy")
HTTPS_PROXY=$(/root/setup/getOvfProperty.py "guestinfo.https_proxy")
PROXY_USERNAME=$(/root/setup/getOvfProperty.py "guestinfo.proxy_username")
PROXY_PASSWORD=$(/root/setup/getOvfProperty.py "guestinfo.proxy_password")
NO_PROXY=$(/root/setup/getOvfProperty.py "guestinfo.no_proxy")
ROOT_PASSWORD=$(/root/setup/getOvfProperty.py "guestinfo.root_password")
ROOT_SSH_KEY=$(/root/setup/getOvfProperty.py "guestinfo.root_ssh_key")
DOCKER_NETWORK_CIDR=$(/root/setup/getOvfProperty.py "guestinfo.docker_network_cidr")
TANZU_INSTALLER_PORT=$(/root/setup/getOvfProperty.py "guestinfo.tanzu_installer_port")
TANZU_INSTALLER_SECURE_PORT=$(/root/setup/getOvfProperty.py "guestinfo.tanzu_installer_secure_port")
ENVOY_ADMIN_INTERFACE=$(/root/setup/getOvfProperty.py "guestinfo.envoy_admin_if")


if [ -e /root/ran_customization ]; then
    exit
else
	TCE_LOG_FILE=/var/log/bootstrap.log
	if [ ${APPLIANCE_DEBUG} == "True" ]; then
		TCE_LOG_FILE=/var/log/bootstrap-debug.log
		set -x
		exec 2>> ${TCE_LOG_FILE}
		echo
        echo "### WARNING -- DEBUG LOG CONTAINS ALL EXECUTED COMMANDS WHICH INCLUDES CREDENTIALS -- WARNING ###"
        echo "### WARNING --             PLEASE REMOVE CREDENTIALS BEFORE SHARING LOG            -- WARNING ###"
        echo
	fi

	echo -e "\e[92mStarting Customization ..." > /dev/console

	echo -e "\e[92mStarting OS Configuration ..." > /dev/console
	. /root/setup/setup-01-os.sh

	echo -e "\e[92mStarting Network Proxy Configuration ..." > /dev/console
	. /root/setup/setup-02-proxy.sh

	echo -e "\e[92mStarting Network Configuration ..." > /dev/console
	. /root/setup/setup-03-network.sh

	echo -e "\e[92mStarting TCE Preparation ..."> /dev/console
	. /root/setup/setup-04-tce-prereqs.sh &

	echo -e "\e[92mStarting Shell Configuration ..." > /dev/console
	. /root/setup/setup-05-shell.sh

	echo -e "\e[92mStarting OS Banner Configuration ..."> /dev/console
	. /root/setup/setup-09-banner.sh &

	# Clear guestinfo.ovfEnv
	vmtoolsd --cmd "info-set guestinfo.ovfEnv NULL"

	echo -e "\e[92mCustomization Completed ..." > /dev/console

	# Ensure we don't run customization again
	touch /root/ran_customization
    # Clean up
	fstrim -v -a
fi