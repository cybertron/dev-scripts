#!/bin/bash

set -eux

pod_data=$(base64 -w 0 pod.yaml)
config_data=$(base64 -w 0 config.yaml)
mc_file='keepalivedv6-mc.yaml'

sed -e "s/@POD/$pod_data/" mc.tmpl | sed -e "s/@CONFIG/$config_data/" > $mc_file

oc delete mc 50-keepalived-v6 || :
oc create -f $mc_file
