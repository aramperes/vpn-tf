resource "random_pet" "droplet-name" {
}

resource "digitalocean_droplet" "vpn-droplet" {
  image  = var.do_droplet_image
  name   = "vpn-${random_pet.droplet-name.id}"
  region = var.do_droplet_region
  size   = var.do_droplet_size
  ssh_keys = [
    data.digitalocean_ssh_key.vpn_admin.id
  ]
  vpc_uuid = var.do_vpc

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.ssh_priv_path)
    timeout     = "2m"
  }

  // Setup
  provisioner "remote-exec" {
    inline = [
      "rm /var/log/wtmp && ln -s /dev/null /var/log/wtmp",
      "service rsyslog stop",
      "systemctl disable rsyslog",
      "NEEDRESTART_MODE=a apt-get -y -o DPkg::Lock::Timeout=60 update",
      "NEEDRESTART_MODE=a apt-get -y -o DPkg::Lock::Timeout=60 install dante-server wireguard"
    ]
  }

  // Dante proxy (SOCKS5) Configuration
  provisioner "file" {
    content = templatefile("${path.module}/files/dante/danted.conf.tftpl", {
      wg_droplet_ip = var.wg_droplet_ip,
      wg_subnet     = var.wg_subnet
    })
    destination = "/etc/danted.conf"
  }

  // WireGuard (VPN) Configuration
  provisioner "file" {
    content = templatefile("${path.module}/files/wireguard/wg0.conf.tftpl", {
      wg_subnet        = var.wg_subnet,
      wg_droplet_ip    = var.wg_droplet_ip,
      wg_droplet_priv  = var.wg_droplet_priv
      wg_peer_pub      = var.wg_peer_pub
      wg_peer_endpoint = var.wg_peer_endpoint
    })
    destination = "/etc/wireguard/wg0.conf"
  }

  // Apply configurations
  provisioner "remote-exec" {
    inline = [
      "systemctl enable wg-quick@wg0.service",
      "systemctl start wg-quick@wg0",
      "systemctl enable danted.service",
      "systemctl restart danted.service",
      "systemctl daemon-reload",
    ]
  }

  // Finalizer: disable root login
  provisioner "remote-exec" {
    inline = [
      "sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config",
      "rm /root/.ssh/authorized_keys",
      "service ssh restart",
    ]
  }
}

resource "digitalocean_firewall" "vpn-tf" {
  name        = "vpn-firewall-${random_pet.droplet-name.id}"
  droplet_ids = [digitalocean_droplet.vpn-droplet.id]

  inbound_rule {
    protocol         = "udp"
    port_range       = 51820
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}
