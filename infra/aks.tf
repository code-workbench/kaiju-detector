# Create Log Analytics Workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.prefix}-law"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Create Azure Kubernetes Service (AKS) with private endpoint
resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.prefix}-aks"
  
  # Private cluster configuration
  private_cluster_enabled             = true
  private_dns_zone_id                = "System"
  private_cluster_public_fqdn_enabled = false

  default_node_pool {
    name            = "default"
    node_count      = var.node_count
    vm_size         = var.node_vm_size
    vnet_subnet_id  = var.existing_aks_subnet_id != null ? var.existing_aks_subnet_id : azurerm_subnet.aks[0].id
    enable_auto_scaling = true
    min_count       = 1
    max_count       = 5
    enable_node_public_ip = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    load_balancer_sku  = "standard"
    outbound_type      = "loadBalancer"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Role assignment for AKS to access the subnet
resource "azurerm_role_assignment" "aks_subnet" {
  count                = var.existing_aks_subnet_id == null ? 1 : 0
  scope                = azurerm_subnet.aks[0].id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.main.identity[0].principal_id
}