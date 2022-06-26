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

echo -e "\e[92mSwitching IP Tables default policies  ..." > /dev/console
#systemctl stop iptables
#systemctl disable iptables
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

cat > /root/setup/openssl-nginx.cnf << __CUSTOMIZE_PHOTON__
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
openssl req -sha256 -nodes -newkey rsa:2048 -keyout /etc/ssl/private/tce-demo-nginx.key -out /tmp/tce-demo-nginx.csr -config /root/setup/openssl-nginx.cnf
#Create certificate and sign it by own certificate authority (valid 1 year)
openssl x509 -req -days 365 -in /tmp/tce-demo-nginx.csr -CA /etc/ssl/certs/tce-demo-tce-demo-ca.pem -CAkey /etc/ssl/private/tce-demo-ca.key -CAcreateserial -extensions req_ext -extfile /root/setup/openssl-nginx.cnf -out /etc/ssl/certs/tce-demo-tce-demo-nginx.pem
#Create SSL chain
cat /etc/ssl/certs/tce-demo-tce-demo-nginx.pem /etc/ssl/certs/tce-demo-tce-demo-ca.pem >> /etc/ssl/certs/tce-demo-chain.pem


echo '\e[92mSetting up Reverse Proxy...' > /dev/console

cat > /etc/nginx/nginx.conf << "__CUSTOMIZE_PHOTON__"
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    #include       mime.types;
    #default_type  application/octet-stream;
    #sendfile        on;
    #keepalive_timeout  65;

    server {
      listen XXXX;
      server_name  _;
      ssl_certificate      /etc/ssl/certs/tce-demo-chain.pem;
      ssl_certificate_key  /etc/ssl/private/tce-demo-nginx.key;
      ssl_prefer_server_ciphers on;
      location / {
          proxy_pass XXXX;
          proxy_bind 127.0.0.1;
          proxy_buffering off;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
          proxy_set_header Host $host;
 #         proxy_set_header X-Real-IP	$remote_addr;
 #         proxy_set_header X-Forwarded-For	$proxy_add_x_forwarded_for;
 #         proxy_set_header X-Forwarded-Proto	$scheme;
 #         proxy_set_header X-Forwarded-Host	$host;
 #         proxy_set_header X-Forwarded-Port	$server_port;
      }
    }
}
__CUSTOMIZE_PHOTON__

# Doing an extra sed call as the above here doc needs to preserve variables
sed -i -e 's/listen XXXX;/listen '"$TANZU_INSTALLER_SECURE_PORT"' ssl;/' /etc/nginx/nginx.conf
sed -i -e 's/proxy_pass XXXX;/proxy_pass http:\/\/127.0.0.1:'"$TANZU_INSTALLER_PORT"';/' /etc/nginx/nginx.conf

echo '\e[92mActivating Reverse Proxy service...' > /dev/console
systemctl enable nginx
systemctl restart nginx


# End of Script
