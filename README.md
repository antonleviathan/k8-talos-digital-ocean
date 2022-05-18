# Opinionated Self Sovereign Digital Ocean K8 Cluster
* Runs on [Talos Linux](https://www.talos.dev/)

## Setup
1. Put your Digital Ocean API token inside of `terraform.tfvars` file in the root of the project:
```
do_token=<your_token>
```
2. Deploy the infrastructure using terraform
3. Run the following commands to config the Talos cluster (make sure you're in the `talos-config` dir):
  * [docs](https://www.talos.dev/v1.0/talos-guides/install/cloud-platforms/digitalocean/#bootstrap-etcd)
  * run: `talosctl --talosconfig talosconfig kubeconfig .` inside of talos-config/
4. Deploy the Digital Ocean Network Controller:
  * Create secret for LB to use: `kubectl --kubeconfig=kubeconfig create secret generic digitalocean --from-literal=access-token=<your_token> -n kube-system`
  * Deploy: `kubectl --kubeconfig=kubeconfig apply -f digital-ocean-cloud-controller-manager.yaml`
  * make sure your token starts with `dop_v1_`
5. Depoy the ingress-nginx:
  * `kubectl --kubeconfig=kubeconfig apply -f k8-ingress-.yaml`

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
