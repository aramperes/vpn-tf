resource "digitalocean_droplet" "vpn-droplet" {
  image  = "ubuntu-22-04-x64"
  name   = "vpn-tf" // todo: randomize ?
  region = "tor1"
  size   = "s-1vcpu-1gb"
  ssh_keys = [
    data.digitalocean_ssh_key.vpn_admin.id
  ]
  vpc_uuid = var.do_vpc

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.pvt_key)
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
      wg_self_ip = var.wg_self_ip,
      wg_subnet  = var.wg_subnet
    })
    destination = "/etc/danted.conf"
  }

  // Apply configurations
  provisioner "remote-exec" {
    inline = [
      "systemctl restart danted.service"
    ]
  }

  // Finalizer: disable root login
  #   provisioner "remote-exec" {
  #     inline = [
  #       "sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config",
  #       "rm /root/.ssh/authorized_keys",
  #       "service ssh restart",
  #     ]
  #   }
}
