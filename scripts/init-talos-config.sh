#!/bin/bash

# TODO(RyanSquared): find better strategy for cleaning up configs
rm -rf talos-config/;
mkdir -p talos-config;
cd talos-config;
talosctl gen config --config-patch-control-plane=@../files/control-plane-load-balancer-labels.json talos-k8s-digital-ocean https://"$1":443;
