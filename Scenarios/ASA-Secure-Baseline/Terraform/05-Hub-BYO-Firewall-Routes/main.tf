### Notice about changes ######################################################
# We recommend the use of parameters.tfvars for changes.
# Have a particular customization in mind not addressable via parameters.tfvars?
#  Consider filing a feature request at 
#  https://github.com/Azure/azure-spring-apps-landing-zone-accelerator/issues 
# 


data "terraform_remote_state" "lz-network" {
  backend = "azurerm"

  config = {
    storage_account_name = var.state_sa_name
    container_name       = var.state_sa_container_name
    key                  = "lz-network"
    resource_group_name  = var.state_sa_rg
  }
}

locals  {
  # Vnet Data can be read from existing state file or local variables
 
  spoke_vnet_name            = data.terraform_remote_state.lz-network.outputs.spoke_vnet_name
  spoke_rg                   = data.terraform_remote_state.lz-network.outputs.spoke_rg
 
  subnet_shared_name       = var.shared-subnet-name
  subnet_cloudapps_name    = var.springboot-apps-subnet-name
  subnet_cloudsvc_name     = var.springboot-service-subnet-name
  subnet_cloudsupport_name = var.springboot-support-subnet-name
  
}

# Get info about the existing Spoke RG
data "azurerm_resource_group" "spoke_rg" {
  name                = local.spoke_rg
}

# Get info about the existing Spoke VNET and subnets
data "azurerm_virtual_network" "spoke_vnet" {
  name                = local.spoke_vnet_name
  resource_group_name = local.spoke_rg
}

data "azurerm_subnet" "snetsharedsubnet" {
  name                 =  local.subnet_shared_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}

data "azurerm_subnet" "azuresbcloudapps" {
  name                 =  local.subnet_cloudapps_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}

data "azurerm_subnet" "azuresbcloudsvc" {
  name                 =  local.subnet_cloudsvc_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}

data "azurerm_subnet" "azuresbcloudsupport" {
  name                 =  local.subnet_cloudsupport_name
  virtual_network_name =  local.spoke_vnet_name
  resource_group_name  =  local.spoke_rg
}

