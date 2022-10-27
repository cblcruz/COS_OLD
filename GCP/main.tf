# Cribl Stream/Edge Terraform Povisioning with Ansible Deployment
# Author: Claudio Cruz

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.41.0"
    }
  }
}

provider "google" {
  credentials = file("gcp_criblpov.json")
  project     = var.project
  region      = var.region
  zone        = var.zone
}

provider "tls" {
  // no config needed
}

resource "tls_private_key" "linux_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_private_key_pem" {
  content         = tls_private_key.linux_key.private_key_pem
  filename        = "linuxkey.pem"
  file_permission = "400"
}

# Virtual Private Network
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

module "cribl-leader" {
  source   = ".//modules/leader"
  network  = google_compute_network.vpc_network.name
  ssh-key  = tls_private_key.linux_key.public_key_openssh
  username = var.username

}

module "cribl-workers" {
  source        = ".//modules/workers"
  workers_count = var.workers_count
}

module "satellit-box" {
  source = ".//modules/satellite"
  count  = var.satellite_box ? 1 : 0
}
