terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

variable "do_token" {
  sensitive = true
}

variable "ssh_priv_path" {
}

variable "do_vpc" {
}

variable "do_ssh_key_name" {
}

variable "do_droplet_size" {
  default = "s-1vcpu-1gb"
}

variable "do_droplet_region" {
  default = "tor1"
}

variable "do_droplet_image" {
  default = "ubuntu-22-04-x64"
}

variable "wg_self_ip" {
}

variable "wg_subnet" {
}

variable "wg_self_priv" {
  sensitive = true
}

variable "wg_peer_pub" {
}

variable "wg_peer_endpoint" {
  nullable = true
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "vpn_admin" {
  name = var.do_ssh_key_name
}
