module "keyvault" {
  source = "../private_endpoint"
  for_each = {
    for key, value in try(var.private_endpoints.keyvaults, {}) : key => value
    if can(value.lz_key) == false
  }
  base_tags           = var.base_tags
  client_config       = var.client_config
  global_settings     = var.global_settings
  location            = var.vnet_location # The private endpoint must be deployed in the same region as the virtual network.
  name                = try(each.value.name, each.key)
  private_dns         = var.private_dns
  resource_group_name = try(var.resource_groups[each.value.resource_group_key].name, var.vnet_resource_group_name)
  resource_id         = can(each.value.resource_id) ? each.value.resource_id : var.remote_objects.keyvaults[var.client_config.landingzone_key][each.key].id
  settings            = each.value
  subnet_id           = var.subnet_id
  subresource_names   = ["vault"]
}
module "keyvault_remote" {
  source = "../private_endpoint"
  for_each = {
    for key, value in try(var.private_endpoints.keyvaults, {}) : key => value
    if can(value.lz_key)
  }
  base_tags           = var.base_tags
  client_config       = var.client_config
  global_settings     = var.global_settings
  location            = var.vnet_location # The private endpoint must be deployed in the same region as the virtual network.
  name                = try(each.value.name, each.key)
  private_dns         = var.private_dns
  resource_group_name = try(var.resource_groups[each.value.resource_group_key].name, var.vnet_resource_group_name)
  resource_id         = can(each.value.key) ? var.remote_objects.keyvaults[each.value.lz_key][each.value.key].id : var.remote_objects.keyvaults[each.value.lz_key][each.key].id
  settings            = each.value
  subnet_id           = var.subnet_id
  subresource_names   = ["vault"]
}