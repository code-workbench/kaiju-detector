output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.main.name
}

output "acr_login_server" {
  description = "Login server for the Azure Container Registry"
  value       = azurerm_container_registry.main.login_server
}

output "acr_id" {
  description = "ID of the Azure Container Registry"
  value       = azurerm_container_registry.main.id
}

output "acr_subnet_id" {
  description = "ID of the ACR subnet"
  value       = var.existing_acr_subnet_id != null ? var.existing_acr_subnet_id : azurerm_subnet.acr[0].id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "aks_private_fqdn" {
  description = "Private FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.private_fqdn
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = var.existing_vnet_id != null ? var.existing_vnet_id : azurerm_virtual_network.main[0].id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = var.existing_vnet_id != null ? data.azurerm_virtual_network.existing[0].name : azurerm_virtual_network.main[0].name
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}
