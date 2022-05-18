#!/bin/bash
echo "$1";
echo "$2";

cd talos-config;

talosctl --talosconfig talosconfig config endpoint $1;
talosctl --talosconfig talosconfig config node $1;
talosctl --talosconfig talosconfig bootstrap;
