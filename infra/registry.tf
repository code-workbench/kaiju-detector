# Create subnet for ACR (only if not using existing one)
resource "azurerm_subnet" "acr" {
  count                = var.existing_acr_subnet_id == null ? 1 : 0
  name                 = "${var.prefix}-acr-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = var.existing_vnet_id == null ? azurerm_virtual_network.main[0].name : data.azurerm_virtual_network.existing[0].name
  address_prefixes     = var.acr_subnet_address_prefixes
}

# Data source for existing ACR subnet
data "azurerm_subnet" "existing_acr" {
  count                = var.existing_acr_subnet_id != null ? 1 : 0
  name                 = split("/", var.existing_acr_subnet_id)[10]
  virtual_network_name = split("/", var.existing_acr_subnet_id)[8]
  resource_group_name  = split("/", var.existing_acr_subnet_id)[4]
}

# Create Azure Container Registry (ACR)
resource "azurerm_container_registry" "main" {
  name                = "${var.prefix}acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Premium"  # Required for private endpoints
  admin_enabled       = false
  
  # Enable private endpoint
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Create private DNS zone for ACR
resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Link private DNS zone to virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "${var.prefix}-acr-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = var.existing_vnet_id != null ? var.existing_vnet_id : azurerm_virtual_network.main[0].id
  registration_enabled  = false

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Create private endpoint for ACR
resource "azurerm_private_endpoint" "acr" {
  name                = "${var.prefix}-acr-pe"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = var.existing_acr_subnet_id != null ? var.existing_acr_subnet_id : azurerm_subnet.acr[0].id

  private_service_connection {
    name                           = "${var.prefix}-acr-psc"
    private_connection_resource_id = azurerm_container_registry.main.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.acr.id]
  }

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Role assignment for AKS to pull images from ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}