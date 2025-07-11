# Create subnet for jumpbox VM
resource "azurerm_subnet" "jumpbox" {
  name                 = "${var.prefix}-jumpbox-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = var.existing_vnet_id == null ? azurerm_virtual_network.main[0].name : data.azurerm_virtual_network.existing[0].name
  address_prefixes     = var.jumpbox_subnet_address_prefixes
}

# Create public IP for jumpbox
resource "azurerm_public_ip" "jumpbox" {
  name                = "${var.prefix}-jumpbox-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Create Network Security Group for jumpbox
resource "azurerm_network_security_group" "jumpbox" {
  name                = "${var.prefix}-jumpbox-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Associate Network Security Group to jumpbox subnet
resource "azurerm_subnet_network_security_group_association" "jumpbox" {
  subnet_id                 = azurerm_subnet.jumpbox.id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}

# Create network interface for jumpbox
resource "azurerm_network_interface" "jumpbox" {
  name                = "${var.prefix}-jumpbox-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jumpbox.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}

# Create jumpbox virtual machine
resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                = "${var.prefix}-jumpbox-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.jumpbox_vm_size
  admin_username      = var.jumpbox_admin_username

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.jumpbox.id,
  ]

  admin_ssh_key {
    username   = var.jumpbox_admin_username
    public_key = var.jumpbox_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = var.environment
    Project     = "kaiju-detector"
  }
}