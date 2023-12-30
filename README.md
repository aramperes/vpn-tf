# vpn-tf

This Terraform project creates a VPN endpoint using WireGuard and sets up a Dante SOCKS5 proxy server. The infrastructure is deployed on DigitalOcean, and it allows you to establish secure and private connections over the internet.

This project is for educational purposes only. This is my first Terraform project.

## Prerequisites

Before using this Terraform project, make sure you have the following prerequisites:

- [Terraform](https://www.terraform.io/) installed on your local machine.
- A DigitalOcean account and a [Personal Access Token](https://docs.digitalocean.com/reference/api/create-personal-access-token/) for authentication.
- An SSH key pair for accessing the created droplets. You should also [upload the public key](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/to-team/) to your DigitalOcean account.
- A device with WireGuard installed. On Windows, create a new empty tunnel and record the public key. On Linux, generate a private/public key combination using `wg genkey` and `wg pubkey`.

## Usage

1. Clone this repository to your local machine:

    ```bash
    git clone https://github.com/aramperes/vpn-tf.git
    cd vpn-tf
    ```

2. Create a `terraform.tfvars` file with the required variables:

    ```hcl
    # terraform.tfvars

    do_token = "your_digitalocean_token"
    ssh_priv_path = "/path/to/your/private/key"
    do_ssh_key_name = "your_ssh_key_name" # Name of SSH key on DigitalOcean. Must be the public key that matches the private key in "ssh_priv_path".
    do_vpc = "your_digitalocean_vpc_id" # Copy the UUID of the DigitalOcean VPN this droplet should be created under. Recomend creating a separate VPC for this.
    do_droplet_size = "s-1vcpu-1gb"
    do_droplet_region = "tor1"
    do_droplet_image = "ubuntu-22-04-x64"
    wg_self_ip = "10.0.0.2"  # Update with a unique internal IP for the WireGuard endpoint
    wg_subnet = "10.0.0.0/24"  # Update with the WireGuard address range that should be allowed to connect to your VPN.
    wg_self_priv = "your_private_key"  # Update with your private WireGuard key
    wg_peer_pub = "peer_public_key"  # Update with the public key of the peer (from Prerequisites)
    ```

3. Initialize and apply the Terraform configuration:

    ```bash
    terraform init
    terraform apply
    ```

4. Confirm the deployment by typing `yes` when prompted.

5. After the deployment is complete, run `terraform show` to display the DigitalOcean IP address:

    ```bash
    terraform show
    ```

    Look for the `ipv4_address` attribute under the `digitalocean_droplet` resource. This is the IP address of your deployed droplet.
