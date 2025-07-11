# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  
  # Configure for Azure Government or Azure Commercial
  environment = var.azure_environment
  
  # Optional: Set specific endpoints for Azure Government
  # These will be ignored if environment is set to "public" (Azure Commercial)
  dynamic "azure_government" {
    for_each = var.azure_environment == "usgovernment" ? [1] : []
    content {
      # Azure Government specific configuration if needed
    }
  }
}

# Create a resource group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Create Virtual Network (only if not using existing one)
resource "azurerm_virtual_network" "main" {
  count               = var.existing_vnet_id == null ? 1 : 0
  name                = "${var.prefix}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Data source for existing virtual network
data "azurerm_virtual_network" "existing" {
  count               = var.existing_vnet_id != null ? 1 : 0
  name                = split("/", var.existing_vnet_id)[8]
  resource_group_name = split("/", var.existing_vnet_id)[4]
}

# Create subnet for AKS (only if not using existing one)
resource "azurerm_subnet" "aks" {
  count                = var.existing_aks_subnet_id == null ? 1 : 0
  name                 = "${var.prefix}-aks-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = var.existing_vnet_id == null ? azurerm_virtual_network.main[0].name : data.azurerm_virtual_network.existing[0].name
  address_prefixes     = var.aks_subnet_address_prefixes
}

# Data source for existing AKS subnet
data "azurerm_subnet" "existing_aks" {
  count                = var.existing_aks_subnet_id != null ? 1 : 0
  name                 = split("/", var.existing_aks_subnet_id)[10]
  virtual_network_name = split("/", var.existing_aks_subnet_id)[8]
  resource_group_name  = split("/", var.existing_aks_subnet_id)[4]
}

# Create subnet for other services (only if not using existing one)
resource "azurerm_subnet" "services" {
  count                = var.existing_vnet_id == null ? 1 : 0
  name                 = "${var.prefix}-services-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = var.services_subnet_address_prefixes
}


