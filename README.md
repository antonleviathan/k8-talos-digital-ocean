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
  * run `doctl compute droplet get --format PublicIPv4 <droplet ID>`
    * you can find the 1st control plane in your Digital Ocean dash (it's in the URL of your droplet)
  * run the `init-cluster.sh` script
  * run: `talosctl --talosconfig talosconfig kubeconfig .` inside of talos-config/

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
