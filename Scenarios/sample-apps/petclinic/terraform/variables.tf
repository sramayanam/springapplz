variable "subscription_id" {
  type    = string
  default = "a5dc76bb-fb9c-460f-bc90-a9dd011b12ca"
}
variable "resource_group" {
  type    = string
  default = "rg-srramsplza-SPOKE"
}
variable "spring_cloud_service" {
  type = string
}
variable "spring_cloud_resource_group_name" {
  type    = string
  default = "rg-srramsplza-APPS"
}

variable "private_zones_resource_group_name" {
  type    = string
  default = "rg-srramsplza-PRIVATEZONES"
}

variable "key_vault_rg" {
  type    = string
  default = "rg-srramsplza-SHARED"
}
variable "api_gateway" {
  type    = string
  default = "api-gateway"
}
variable "admin_server" {
  type    = string
  default = "admin-server"
}
variable "customers_service" {
  type    = string
  default = "customers-service"
}
variable "visits_service" {
  type    = string
  default = "visits-service"
}
variable "vets_service" {
  type    = string
  default = "vets-service"
}

variable "mysql_server_admin_username" {
  type    = string
  default = "sqlAdmin"
}

variable "mysql_server_admin_password" {
  type = string
}

variable "mysql_database_name" {
  type    = string
  default = "petclinic"
}

variable "mysql_CIDR" {
  type    = string
  default = "10.1.6.0/24"

}
