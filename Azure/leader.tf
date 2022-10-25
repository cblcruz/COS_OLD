# Azure Public IP allocation for the Cribl Leader.
resource "azurerm_public_ip" "leader" {
  name                = "cribl-leader-VM-IP"
  resource_group_name = azurerm_resource_group.cribl.name
  location            = azurerm_resource_group.cribl.location
  allocation_method   = "Dynamic"
  tags = {
    environment = "POV"
  }
}

# Azure Net Interface to be used by this instance(s) 
resource "azurerm_network_interface" "cribl_leader" {
  name                = "cribl-leader-NIC-01"
  location            = azurerm_resource_group.cribl.location
  resource_group_name = azurerm_resource_group.cribl.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cribl.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.leader.id

  }
}

# Azure Linux Virtual Maching for the Cribl Stream Leader
resource "azurerm_linux_virtual_machine" "leader" {
  name                  = "cribl-POV-leader"
  resource_group_name   = azurerm_resource_group.cribl.name
  location              = azurerm_resource_group.cribl.location
  size                  = "Standard_ds1_v2"
  admin_username        = "povadmin"
  computer_name         = "leader"
  network_interface_ids = [azurerm_network_interface.cribl_leader.id]

  admin_ssh_key {
    username   = "povadmin"
    public_key = tls_private_key.linux_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.cribl_leader,
    tls_private_key.linux_key
  ]

}

resource "null_resource" "Ansible_Leader" {
  connection {
    #host        = self.public_ip_address
    host        = azurerm_linux_virtual_machine.leader.public_ip_address
    user        = "povadmin"
    type        = "ssh"
    private_key = tls_private_key.linux_key.private_key_openssh
  }

  triggers = {
    network_interface_ids = "${join(",", azurerm_network_interface.cribl_leader.*.id)}"
  }

  provisioner "local-exec" {

    command = "sleep 30;ansible-playbook -i '${azurerm_linux_virtual_machine.leader.public_ip_address},' --private-key linuxkey.pem ./ansible/deployleader.yaml"
  }
  depends_on = [
    azurerm_linux_virtual_machine.leader,
    azurerm_network_interface.cribl_leader,
    tls_private_key.linux_key
  ]
}

resource "local_file" "cribl-vars" {
  content  = <<-DOC
  leader_ip: ${azurerm_linux_virtual_machine.leader.public_ip_address}
  Leader Host: ${azurerm_linux_virtual_machine.leader.computer_name}
  
  DOC
  filename = "ansible/cribl_vars.yml"

  depends_on = [azurerm_network_interface.cribl_leader,
    azurerm_linux_virtual_machine.leader,
  ]
}
# Azure Security Group for the Leader for the Cribl Leader.
resource "azurerm_network_security_group" "leader" {
  name                = "leader-security-group1"
  location            = azurerm_resource_group.cribl.location
  resource_group_name = azurerm_resource_group.cribl.name

  tags = {
    environment = "POV"
  }
}

resource "azurerm_network_security_rule" "leader-sec-rules" {
  for_each                    = local.leader
  name                        = each.key
  direction                   = each.value.direction
  access                      = each.value.access
  priority                    = each.value.priority
  protocol                    = each.value.protocol
  source_port_range           = each.value.source_port_range
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = azurerm_resource_group.cribl.name
  network_security_group_name = azurerm_network_security_group.leader.name
}

# Azure Security Group attached to the Cribl Leader Network Interface
resource "azurerm_network_interface_security_group_association" "leader" {
  count                     = 1
  network_interface_id      = element(azurerm_network_interface.cribl_leader.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.leader.id
}

