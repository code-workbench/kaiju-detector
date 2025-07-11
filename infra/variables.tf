variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-kaiju-detector"
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "kaiju"
}

variable "environment" {
  description = "The environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "node_count" {
  description = "The initial number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "node_vm_size" {
  description = "The size of the Virtual Machine for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "existing_vnet_id" {
  description = "Resource ID of existing virtual network. If provided, will use existing VNet instead of creating new one."
  type        = string
  default     = null
}

variable "existing_aks_subnet_id" {
  description = "Resource ID of existing AKS subnet. Required if using existing VNet."
  type        = string
  default     = null
}

variable "existing_services_subnet_id" {
  description = "Resource ID of existing services subnet. Optional when using existing VNet."
  type        = string
  default     = null
}

# Network CIDR blocks
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_address_prefixes" {
  description = "Address prefixes for the AKS subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "services_subnet_address_prefixes" {
  description = "Address prefixes for the services subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "service_cidr" {
  description = "CIDR block for Kubernetes services"
  type        = string
  default     = "10.1.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address for the Kubernetes DNS service"
  type        = string
  default     = "10.1.0.10"
}

# Jumpbox configuration
variable "jumpbox_subnet_address_prefixes" {
  description = "Address prefixes for the jumpbox subnet"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

variable "jumpbox_vm_size" {
  description = "Size of the jumpbox VM"
  type        = string
  default     = "Standard_B2s"
}

variable "jumpbox_admin_username" {
  description = "Admin username for the jumpbox VM"
  type        = string
  default     = "azureuser"
}

variable "jumpbox_ssh_public_key" {
  description = "SSH public key for the jumpbox VM admin user"
  type        = string
}

# Variables for Azure Container Registry
variable "existing_acr_subnet_id" {
  description = "ID of existing ACR subnet (leave null to create new subnet)"
  type        = string
  default     = null
}

variable "acr_subnet_address_prefixes" {
  description = "Address prefixes for ACR subnet"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

# Azure cloud environment configuration
variable "azure_environment" {
  description = "Azure cloud environment - 'public' for Azure Commercial, 'usgovernment' for Azure Government"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "usgovernment"], var.azure_environment)
    error_message = "azure_environment must be either 'public' (Azure Commercial) or 'usgovernment' (Azure Government)."
  }
}

variable "storage_subnet_address_prefixes" {
  description = "Address prefixes for the storage subnet"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}
