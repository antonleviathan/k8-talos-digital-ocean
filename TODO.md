- [ ] Update talos image source to something more reliable
- [ ] Use S3 for managing statefile
- [ ] Validate talos config files
  * [docs](https://www.talos.dev/v1.0/talos-guides/install/cloud-platforms/digitalocean/#validate-the-configuration-files)
- [ ] Add to controlplane.yaml:
    * `extraArgs: {"node-labels": "node.kubernetes.io/exclude-from-external-load-balancers=true"}`
- [ ] Write terraform for setting up AWS Route 53
- [ ] Use sops to encrypt sensitive files
- [ ] K8 deployment file for cert manager