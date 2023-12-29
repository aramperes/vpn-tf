terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {
}

variable "pvt_key" {
}

variable "do_vpc" {
}

variable "wg_self_ip" {
}

variable "wg_subnet" {
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "vpn_admin" {
  name = "vpn-admin"
}
