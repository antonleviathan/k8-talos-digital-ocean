# Opinionated Self Sovereign Digital Ocean K8 Cluster
* Runs on [Talos Linux](https://www.talos.dev/)

## Setup
1. Put your Digital Ocean API tokens inside of `terraform.tfvars` file in the root of the project:
```
do_token=<f0...your_token>
lb_token=<dop_v1_your_token>
```
2. Deploy using terraform: `terraform apply`

