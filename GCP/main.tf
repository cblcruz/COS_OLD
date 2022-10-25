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

module "cribl-leader" {
  source = ".//modules/leader"
}

module "cribl-workers" {
  source        = ".//modules/workers"
  workers_count = var.workers_count
}