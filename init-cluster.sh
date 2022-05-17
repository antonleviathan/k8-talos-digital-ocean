#!/bin/bash
echo "$1";
echo "$2";

cd talos-config;
pwd;

echo "$dropletIP";

if [ $2 = "talos-control-plane-3" ]; then
  for arg
  do
    talosctl --talosconfig talosconfig config endpoint $1;
    talosctl --talosconfig talosconfig config node $1;
    talosctl --talosconfig talosconfig bootstrap;
  done
fi
