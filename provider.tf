terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
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
  name = "vpn-admin"
}
