#!/bin/bash
# Copyright 2019 VMware, Inc. All rights reserved.
# SPDX-License-Identifier: BSD-2
# cl: v0.12.1-dz-2022-06-13
# Modified by Dominik Zorgnotti for TCE appliance



# Setup Docker and TCE pre-reqs

set -euo pipefail

echo -e "\e[92mStarting Docker ..." > /dev/console
systemctl daemon-reload
systemctl start docker.service
systemctl enable docker.service

echo -e "\e[92mSwitching IP Tables default policies  ..." > /dev/console
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables-save >/etc/systemd/scripts/ip4save


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
TimeoutStartSec=1min
RestartSec=1min
ExecStart=/usr/local/bin/tanzu management-cluster create --ui --bind 0.0.0.0:$TANZU_INSTALLER_PORT --browser none --timeout 24h
StandardOutput=append:/var/log/tanzu-ce.log
StandardError=inherit

[Install]
WantedBy=multi-user.target
__CUSTOMIZE_PHOTON__

echo '\e[92mActivating TCE installer service...' > /dev/console
systemctl daemon-reload
systemctl enable tanzu-bootstrap.service
sleep 5
systemctl start tanzu-bootstrap.service


echo '\e[92mSetting up SSL certs...' > /dev/console
# Going down with traditional RSA based keys for backwards compatibulity

IP_ETH0=$(ip -o -4 a | awk '$2 == "eth0" { gsub(/\/.*/, "", $4); print $4 }')

cat > /root/setup/openssl-ca.cnf << __CUSTOMIZE_PHOTON__
[ req ]
prompt = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C = DE
ST = NRW     
L = Cologne    
O = Why did IT fail
OU = LAB      
CN = Why did IT fail LAB CA
emailAddress = dominik@why-did-it.fail
__CUSTOMIZE_PHOTON__

cat > /root/setup/openssl-revproxy.cnf << __CUSTOMIZE_PHOTON__
[req]
default_bits  = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
C = DE
ST = NRW     
L = Cologne    
O = Why did IT fail
OU = LAB      
commonName = $(hostname -f)

[req_ext]
subjectAltName = @alt_names

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = $IP_ETH0
DNS.1 = $(hostname -f)
__CUSTOMIZE_PHOTON__


#Generate a CA private key and CA Certificate (valid for 5 years)
openssl req -nodes -new -x509 -keyout /etc/ssl/private/tce-demo-ca.key -out /etc/ssl/certs/tce-demo-tce-demo-ca.pem -days 1825 -config /root/setup/openssl-ca.cnf
#Generate web server secret key and CSR
openssl req -sha256 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/tce-demo-revproxy.key -out /tmp/tce-demo-revproxy.csr -config /root/setup/openssl-revproxy.cnf
#Create certificate and sign it by own certificate authority (valid 1 year)
openssl x509 -req -days 365 -in /tmp/tce-demo-revproxy.csr -CA /etc/ssl/certs/tce-demo-tce-demo-ca.pem -CAkey /etc/ssl/private/tce-demo-ca.key -CAcreateserial -extensions req_ext -extfile /root/setup/openssl-revproxy.cnf -out /etc/ssl/certs/tce-demo-tce-demo-revproxy.pem
#Create SSL chain
cat /etc/ssl/certs/tce-demo-tce-demo-revproxy.pem /etc/ssl/certs/tce-demo-tce-demo-ca.pem >> /etc/ssl/certs/tce-demo-chain.pem


echo '\e[92mSetting up Reverse Proxy...' > /dev/console
rpm --import 'https://rpm.dl.getenvoy.io/public/gpg.CF716AF503183491.key'
curl -sL 'https://rpm.dl.getenvoy.io/public/config.rpm.txt?distro=el&codename=7' > /etc/yum.repos.d/tetrate-getenvoy-rpm-stable.repo
tdnf install -y getenvoy-envoy

mkdir -p /etc/envoy

cat > /etc/envoy/envoy.yaml << "__CUSTOMIZE_PHOTON__"
static_resources:
  listeners:
  - name: tce-installer
    address:
      socket_address:
        address: 0.0.0.0
        port_value: XXXX
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          request_timeout: 0s
          request_headers_timeout: 0s
          use_remote_address: true
          codec_type: HTTP1
          server_header_transformation: PASS_THROUGH
          upgrade_configs:
          - upgrade_type: websocket
          stat_prefix: ingress_http
          route_config:
            name: local_route
            virtual_hosts:
            - name: app
              domains:
              - "*"
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: tanzu-installer-ui
                  timeout: 0s
                  idle_timeout: 0s
                  auto_host_rewrite: true
                  prefix_rewrite: "/"
                  internal_redirect_policy:
                    max_internal_redirects: 5
                  upgrade_configs:
                    - upgrade_type: websocket
          http_filters:
          - name: envoy.filters.http.router
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
      transport_socket:
        name: envoy.transport_sockets.tls
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.DownstreamTlsContext
          common_tls_context:
            tls_certificates:
            - certificate_chain: {filename: "/etc/ssl/certs/tce-demo-chain.pem"}
              private_key: {filename: "/etc/ssl/private/tce-demo-revproxy.key"}
  clusters:
  - name: tanzu-installer-ui
    connect_timeout: 10s
    lb_policy: ROUND_ROBIN
    common_http_protocol_options:
      idle_timeout: 30s
    load_assignment:
      cluster_name: tanzu-installer-ui
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 127.0.0.1
                port_value: YYYY

__CUSTOMIZE_PHOTON__

# Doing an extra sed call as the above here doc needs to preserve variables
sed -i -e 's/port_value: XXXX/port_value: '"$TANZU_INSTALLER_SECURE_PORT"'/' /etc/envoy/envoy.yaml
sed -i -e 's/port_value: YYYY/port_value: '"$TANZU_INSTALLER_PORT"'/' /etc/envoy/envoy.yaml




# Enable admin access
if [ ${ENVOY_ADMIN_INTERFACE} == "True" ]; then
cat >> /etc/envoy/envoy.yaml << "__CUSTOMIZE_PHOTON__"
admin:
  access_log_path: /tmp/admin_access.log
  address:
    socket_address:
      protocol: TCP
      address: 0.0.0.0
      port_value: 10001
__CUSTOMIZE_PHOTON__
fi


echo '\e[92mCreating Reverse Proxy service...' > /dev/console
cat > /etc/systemd/system/envoy.service << __CUSTOMIZE_PHOTON__
[Unit]
Description=Systemd Service to run the envoy reserve proxy
After=syslog.target network.target auditd.service systemd-journald.socket basic.target system.slice

[Service]
Type=idle
Restart=on-failure
TimeoutStartSec=1min
RestartSec=1min
ExecStart=/usr/bin/envoy -c /etc/envoy/envoy.yaml
StandardOutput=append:/var/log/envoy.log
StandardError=inherit

[Install]
WantedBy=multi-user.target
__CUSTOMIZE_PHOTON__

echo '\e[92mActivating Reverse Proxy service...' > /dev/console
systemctl daemon-reload
systemctl enable envoy.service
sleep 5
systemctl start envoy.service






# End of Script
