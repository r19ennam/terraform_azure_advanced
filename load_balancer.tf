# Create a Public IP for the Load Balancer
resource "azurerm_public_ip" "pip" {
  name                = "lb-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = "${var.resource_group_name}terraformadvanceddns"  # Add this line
}

# Create the Load Balancer
resource "azurerm_lb" "lb" {
  name                = "lb"
  location            = var.location
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "default"
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}


# Create Backend Address Pool
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "backend-address-pool"
}

# Create Health Probe
resource "azurerm_lb_probe" "main" {
  loadbalancer_id     = azurerm_lb.lb.id
  name                = "health-probe"
  port                = 5000
}

# Create Load Balancing Rule
resource "azurerm_lb_rule" "main" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 5000
  backend_port                   = 5000
  frontend_ip_configuration_name = "default"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.main.id
}