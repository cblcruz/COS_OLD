# Azure Net Interface to be used by this instance(s) 
resource "azurerm_network_interface" "worker" {
  count               = var.workers_count
  name                = "cribl-worker-NIC-${count.index}"
  location            = azurerm_resource_group.cribl.location
  resource_group_name = azurerm_resource_group.cribl.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cribl.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.worker.*.id, count.index)

  }
}

resource "azurerm_availability_set" "workers-lb" {
  count               = var.lb_create ? 1 : 0
  name                = "FrontEndIP"
  location            = azurerm_resource_group.cribl.location
  resource_group_name = azurerm_resource_group.cribl.name
}

# Azure Linux Virtual Maching for the Cribl Stream Leader
resource "azurerm_linux_virtual_machine" "worker" {
  name                = "cribl-POV-worker-${count.index}"
  count               = var.workers_count
  resource_group_name = azurerm_resource_group.cribl.name
  location            = azurerm_resource_group.cribl.location
  size                = var.worker_size
  admin_username      = "povadmin"
  availability_set_id = var.lb_create ? azurerm_availability_set.workers-lb[0].id : null
  network_interface_ids = [
    element(azurerm_network_interface.worker.*.id, count.index)
    ,
  ]
  tags = {
    ansible-group = "workers"
    ansible-index = floor(count.index / var.workers_count)
  }


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
    sku       = "18.04-LTS"
    version   = "latest"
  }

  depends_on = [azurerm_network_interface.cribl_leader,
    azurerm_public_ip.worker,
    azurerm_virtual_network.cribl,
    azurerm_linux_virtual_machine.leader,
    azurerm_network_interface.worker,
    tls_private_key.linux_key
  ]

}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      ansible_group_index = aws_instance.worker.*.tags.ansible-index,
      ansible_group_workers = aws_instance.worker.*.tags.ansible-group,
      workers_ip            = aws_instance.worker.*.public_ip_address,
      }
  )
  filename = "inventory"
}

resource "null_resource" "Ansible4Ubuntu" {
  connection {
    #host        = self.public_ip_address
    host        = join(",", azurerm_linux_virtual_machine.worker.*.public_ip_address)
    user        = "ubuntu"
    type        = "ssh"
    private_key = tls_private_key.linux_key.private_key_openssh
  }

  triggers = {
    network_interface_ids = "${join(",", azurerm_network_interface.worker.*.id)}"
  }

  provisioner "local-exec" {

    # command = "sleep 20;ansible-playbook -i ${join(" ", azurerm_linux_virtual_machine.worker.*.public_ip_address)}, --private-key linuxkey.pem test.yaml"
    command = "sleep 20;ansible-playbook -i inventory --private-key linuxkey.pem deploywrks.yaml"
  }
  depends_on = [azurerm_network_interface.cribl_leader,
    azurerm_network_security_group.worker,
    azurerm_network_security_rule.workers-sec-rules,
    azurerm_linux_virtual_machine.leader,
    azurerm_network_interface.worker,
  tls_private_key.linux_key]

}

# Azure Public IP address(es) allocation for the Cribl Stream Worker(s)
resource "azurerm_public_ip" "worker" {
  count               = var.workers_count
  name                = "worker-VM-NIC-0${count.index}"
  resource_group_name = azurerm_resource_group.cribl.name
  location            = azurerm_resource_group.cribl.location
  allocation_method   = "Dynamic"

  depends_on = [
    azurerm_resource_group.cribl
  ]

  tags = {
    environment = "POV"
  }
}


# Azure Security Group for the Cribl Worker(s).
resource "azurerm_network_security_group" "worker" {
  name                = "worker-security-group1"
  location            = azurerm_resource_group.cribl.location
  resource_group_name = azurerm_resource_group.cribl.name

  tags = {
    environment = "POV"
  }

}

resource "azurerm_network_security_rule" "workers-sec-rules" {
  for_each                    = local.workers
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
  network_security_group_name = azurerm_network_security_group.worker.name
}

# Azure Security Group attached to the Cribl Worker Network Interface
resource "azurerm_network_interface_security_group_association" "worker" {
  count                     = var.workers_count
  network_interface_id      = element(azurerm_network_interface.worker.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.worker.id
}