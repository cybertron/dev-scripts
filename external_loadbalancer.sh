#!/bin/bash

set -ex -o pipefail

source common.sh
source network.sh

#sudo dnf install -y haproxy
sudo firewall-cmd --zone=libvirt --add-port=6443/tcp

haproxy_config="${WORKING_DIR}/haproxy.cfg"

if [ "$IP_STACK" = "v6" ]
then
    master0=fd2e:6f44:5dd8:c956::14
    master1=fd2e:6f44:5dd8:c956::15
    master2=fd2e:6f44:5dd8:c956::16
    virthost=fd2e:6f44:5dd8:c956::1
else
    master0=192.168.111.20
    master1=192.168.111.21
    master2=192.168.111.22
    virthost=192.168.111.1
fi

cat << EOF > "$haproxy_config"
defaults
    mode                    tcp
    log                     global
    timeout connect         10s
    timeout client          1m
    timeout server          1m

frontend main
    bind ${virthost}:6443 v4v6
    default_backend api
backend api
    option  httpchk GET /readyz HTTP/1.0
    option  log-health-checks
    balance roundrobin
    server master-0 ${master0}:6443 check check-ssl inter 1s fall 2 rise 3 verify none
    server master-1 ${master1}:6443 check check-ssl inter 1s fall 2 rise 3 verify none
    server master-2 ${master2}:6443 check check-ssl inter 1s fall 2 rise 3 verify none
EOF

haproxy -f "$haproxy_config"
