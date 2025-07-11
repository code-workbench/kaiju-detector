# Create subnet for storage account private endpoint
resource "azurerm_subnet" "storage" {
  name                 = "${var.prefix}-storage-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = var.existing_vnet_id == null ? azurerm_virtual_network.main[0].name : data.azurerm_virtual_network.existing[0].name
  address_prefixes     = var.storage_subnet_address_prefixes

  # Disable private endpoint network policies
  private_endpoint_network_policies = "Disabled"
}

# Create storage account
resource "azurerm_storage_account" "main" {
  name                     = "${replace(var.prefix, "-", "")}storage${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  
  # Disable public access
  public_network_access_enabled = false
  
  # Enable secure transfer
  https_traffic_only_enabled = true
  
  # Set minimum TLS version
  min_tls_version = "TLS1_2"

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Generate random suffix for storage account name (must be globally unique)
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create private DNS zone for storage blob
resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Link private DNS zone to virtual network
resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob" {
  name                  = "${var.prefix}-storage-blob-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = var.existing_vnet_id == null ? azurerm_virtual_network.main[0].id : var.existing_vnet_id
  registration_enabled  = false

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Create private endpoint for storage account
resource "azurerm_private_endpoint" "storage" {
  name                = "${var.prefix}-storage-pe"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.storage.id

  private_service_connection {
    name                           = "${var.prefix}-storage-psc"
    private_connection_resource_id = azurerm_storage_account.main.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "storage-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_blob.id]
  }

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}