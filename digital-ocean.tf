terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_custom_image" "talos" {
  name    = "talos"
  url     = "https://github.com/antonleviathan/talos-image/raw/3879e5d8bfaaa1a8368f21b06abd1db64a8d2aa6/disk.raw"
  regions = ["sfo3"]
}

resource "digitalocean_vpc" "default" {
  name     = "deafult-sfo3"
  region   = "sfo3"
  ip_range = "10.10.10.0/24"
}

resource "digitalocean_loadbalancer" "public" {
  name     = "loadbalancer-1"
  region   = "sfo3"
  vpc_uuid = digitalocean_vpc.default.id

  forwarding_rule {
    entry_port     = 443
    entry_protocol = "tcp"

    target_port     = 6443
    target_protocol = "tcp"
  }

  healthcheck {
    port                     = 6443
    protocol                 = "tcp"
    check_interval_seconds   = 10
    response_timeout_seconds = 5
    healthy_threshold        = 5
    unhealthy_threshold      = 3
  }

  droplet_tag = "talos-digital-ocean-tutorial-control-plane"

  provisioner "local-exec" {
    command = "cd talos-config; talosctl gen config talos-k8s-digital-ocean-tutorial https://${self.ip}:443"
  }
}

data "local_file" "controlplane" {
  depends_on = [digitalocean_loadbalancer.public]
  filename = "${path.module}/talos-config/controlplane.yaml"
}

data "local_file" "worker" {
  depends_on = [digitalocean_loadbalancer.public]
  filename = "${path.module}/talos-config/worker.yaml"
}

resource "digitalocean_droplet" "control-plane" {
  // Depends on LB as it generates the configs used as `user_data`
  depends_on = [digitalocean_loadbalancer.public]
  for_each = toset([
    "talos-control-plane-1",
    "talos-control-plane-2",
    "talos-control-plane-3"
  ])
  name      = each.key
  region    = "sfo3"
  image     = digitalocean_custom_image.talos.id
  size      = "s-2vcpu-4gb"
  vpc_uuid  = digitalocean_vpc.default.id
  tags      = ["talos-digital-ocean-tutorial-control-plane"]
  user_data = data.local_file.controlplane.content
  ssh_keys  = ["c7:28:d5:da:ca:75:0a:06:f7:69:21:4d:56:6e:17:a7"]

  provisioner "local-exec" {
    command = "./init-cluster.sh ${digitalocean_droplet.control-plane["talos-control-plane-1"].id} ${digitalocean_droplet.control-plane["talos-control-plane-1"].name}"
  }
}

resource "digitalocean_droplet" "worker" {
  // Depends on LB as it generates the configs used as `user_data`
  depends_on = [digitalocean_loadbalancer.public]
  name       = "talos-worker-node-1"
  region     = "sfo3"
  image      = digitalocean_custom_image.talos.id
  size       = "s-2vcpu-4gb"
  vpc_uuid   = digitalocean_vpc.default.id
  user_data  = data.local_file.worker.content
  ssh_keys   = ["c7:28:d5:da:ca:75:0a:06:f7:69:21:4d:56:6e:17:a7"]
}
