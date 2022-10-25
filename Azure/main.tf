# Cribl Stream/Edge Terraform Povisioning with Ansibl Deployment
# Author: Claudio Cruz

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.27.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
# Azure Resource Group - using a single resource group for cribl
resource "azurerm_resource_group" "cribl" {
  name     = "cribl-resources"
  location = var.az_location
}

locals {
  private_key_path = "linuxkey.pem"
}

resource "tls_private_key" "linux_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# We want to save the private key to our machine
# We can then use this key to connect to our Linux VM

resource "local_file" "linuxkey" {
  filename        = "linuxkey.pem"
  file_permission = "600"
  content         = tls_private_key.linux_key.private_key_pem
}


# Azure Network Definition for the Cribl Stream environment, if Cribl Edge is being deployed from a different network,
# changes on the environment network in Azure may be needed
resource "azurerm_virtual_network" "cribl" {
  name                = "cribl-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.cribl.location
  resource_group_name = azurerm_resource_group.cribl.name
  depends_on = [
    azurerm_resource_group.cribl
  ]
}

# Azure Subnet definition to be used by all Cribl resources 
resource "azurerm_subnet" "cribl" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.cribl.name
  virtual_network_name = azurerm_virtual_network.cribl.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "null_resource" "NSCFConstantString" {
  provisioner "local-exec" {
    command = "export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES"
  }
}