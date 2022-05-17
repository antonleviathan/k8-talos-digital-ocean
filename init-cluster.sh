#!/bin/bash
echo "$1";
echo "$2";

cd talos-config;
pwd;

dropletIP=`doctl compute droplet get --format PublicIPv4 $1 | cut -d ' ' -f3`;
echo "$dropletIP";

if [ $2 = "talos-control-plane-3" ]; then
  for arg
  do
    talosctl --talosconfig talosconfig config endpoint $dropletIP;
    talosctl --talosconfig talosconfig config node $dropletIP;
    talosctl --talosconfig talosconfig bootstrap;
  done
fi
