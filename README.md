# Opinionated Self Sovereign Digital Ocean K8 Cluster
* Runs on [Talos Linux](https://www.talos.dev/)

## Setup
1. Put your Digital Ocean API token inside of `terraform.tfvars` file in the root of the project:
```
do_token=<your_token>
```
2. Deploy the infrastructure using terraform
3. CD into talos-config/
  * Retrieve kubecofig: `talosctl --talosconfig talosconfig kubeconfig .`
  * Create secret for LB to use: `kubectl --kubeconfig=kubeconfig create secret generic digitalocean --from-literal=access-token=<your_token> -n kube-system`
      * make sure your token starts with `dop_v1_`
  * Deploy cloud controller manager: `kubectl --kubeconfig=kubeconfig apply -f ../deployments/digital-ocean-cloud-controller-manager.yaml`
  * Depoy the ingress-nginx: `kubectl --kubeconfig=kubeconfig apply -f ../deployments/k8-ingress.yaml`

## TODO
- [ ] Update talos image source to something more reliable
- [ ] Make init-cluster.sh run after terraform deployment is done
- [ ] Use S3 for managing statefile
- [ ] Validate talos config files
  * [docs](https://www.talos.dev/v1.0/talos-guides/install/cloud-platforms/digitalocean/#validate-the-configuration-files)
- [ ] Add to controlplane.yaml:
    * `extraArgs: {"node-labels": "node.kubernetes.io/exclude-from-external-load-balancers=true"}`
- [ ] Write terraform for setting up AWS Route 53
- [ ] Use sops to encrypt sensitive files
- [ ] K8 deployment file for cert manager
