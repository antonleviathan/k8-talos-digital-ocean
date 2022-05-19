#!/bin/bash

rm -rf talos-config/;
mkdir talos-config;
cd talos-config;
talosctl gen config talos-k8s-digital-ocean-tutorial https://$1:443;
