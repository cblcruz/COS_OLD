locals {
  leader = {

    ssh = {
      name                       = "ssh"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

    ui = {
      name                       = "ui"
      priority                   = 101
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "9000"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

    mgt = {
      name                       = "mgt"
      priority                   = 201
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "4200"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
  workers = {

    ssh = {
      name                       = "ssh"
      priority                   = 102
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

    ui = {
      name                       = "ui"
      priority                   = 103
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "9000"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

    mgt = {
      name                       = "mgt"
      priority                   = 202
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "4200"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }

    syslog = {
      name                       = "syslogtcp"
      priority                   = 203
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "9154"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    syslogu = {
      name                       = "syslogudp"
      priority                   = 204
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "9154"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    splunkin = {
      name                       = "splunkin"
      priority                   = 205
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "9997"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    splunksearch = {
      name                       = "splunksearch"
      priority                   = 206
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "8089"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
    tcpjson = {
      name                       = "tcpjson"
      priority                   = 207
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "10097"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }


}