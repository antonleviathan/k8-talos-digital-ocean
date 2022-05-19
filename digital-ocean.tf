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

resource "digitalocean_ssh_key" "dummy" {
  # DigitalOcean requires a key when deploying an image even if the machine
  # will not have SSH access
  name = "Dummy Talos Key"
  public_key = file("files/dummy_key.pub")
}

resource "digitalocean_loadbalancer" "public" {
  name     = "loadbalancer-1"
  region   = "sfo3"

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

  droplet_tag = "talos-digital-ocean-control-plane"

  provisioner "local-exec" {
    command = "sh scripts/init-talos-config.sh ${self.ip}"
  }
}

data "local_file" "controlplane" {
  depends_on = [digitalocean_loadbalancer.public]
  filename   = "${path.module}/talos-config/controlplane.yaml"
}

data "local_file" "worker" {
  depends_on = [digitalocean_loadbalancer.public]
  filename   = "${path.module}/talos-config/worker.yaml"
}

resource "digitalocean_droplet" "control-plane" {
  // Depends on LB as it generates the configs used as `user_data`
  depends_on = [digitalocean_loadbalancer.public]
  count      = 3
  name       = "talos-control-plane-${count.index}"
  region     = "sfo3"
  image      = digitalocean_custom_image.talos.id
  size       = "s-2vcpu-4gb"
  # required by load balancer for routing purposes
  tags       = ["talos-digital-ocean-control-plane"]
  user_data  = data.local_file.controlplane.content
  ssh_keys   = [digitalocean_ssh_key.dummy.fingerprint]
}

resource "digitalocean_droplet" "worker" {
  // Depends on LB as it generates the configs used as `user_data`
  depends_on = [digitalocean_loadbalancer.public, digitalocean_droplet.control-plane]
  name       = "talos-worker-node-1"
  region     = "sfo3"
  image      = digitalocean_custom_image.talos.id
  size       = "s-2vcpu-4gb"
  user_data  = data.local_file.worker.content
  ssh_keys   = [digitalocean_ssh_key.dummy.fingerprint]
}

resource "null_resource" "init-cluster" {
  depends_on = [digitalocean_droplet.worker]

  provisioner "local-exec" {
    command = "sh scripts/init-cluster.sh ${digitalocean_droplet.control-plane[0].ipv4_address}"
  }
}
