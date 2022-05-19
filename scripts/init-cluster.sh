#!/bin/bash

cd talos-config;

talosctl --talosconfig talosconfig config endpoint $1;
talosctl --talosconfig talosconfig config node $1;
talosctl --talosconfig talosconfig bootstrap;
talosctl --talosconfig talosconfig kubeconfig .;

sleep 360;

lb_token=$(cat ../terraform.tfvars | grep 'lb_token=' | cut -d "=" -f2- | tr -d '"');
kubectl --kubeconfig=kubeconfig create secret generic digitalocean --from-literal=access-token=$lb_token -n kube-system;

sleep 30;

kubectl --kubeconfig=kubeconfig apply -f ../deployments;
