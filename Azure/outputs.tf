output "resource_group_name" {
  value = azurerm_resource_group.cribl.name
}

output "Lader_public_ip_address" {
  value = azurerm_linux_virtual_machine.leader.public_ip_address
}

# output "Workers_IP_Addresses" {
#   value = tomap({
#     for name, vm in azurerm_linux_virtual_machine.worker : name => [vm.public_ip_address]
#   })

output "Workers_IP_Addresses" {
  value = {
    for name, vm in azurerm_linux_virtual_machine.worker : name => [vm.public_ip_address]
  }
  depends_on = [
    azurerm_public_ip.worker,
    azurerm_network_interface.worker
  ]
}