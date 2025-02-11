module "machine_learning_workspaces" {
  source   = "./modules/analytics/machine_learning"
  for_each = local.database.machine_learning_workspaces

  client_config           = local.client_config
  resource_groups         = local.combined_objects_resource_groups
  global_settings         = local.global_settings
  settings                = each.value
  vnets                   = local.combined_objects_networking
  storage_account_id      = lookup(each.value, "storage_account_key") == null ? null : module.storage_accounts[each.value.storage_account_key].id
  keyvault_id             = lookup(each.value, "keyvault_key") == null ? null : module.keyvaults[each.value.keyvault_key].id
  application_insights_id = lookup(each.value, "application_insights_key") == null ? null : module.azurerm_application_insights[each.value.application_insights_key].id
  container_registry_id   = try(each.value.container_registry_key, null) == null ? null : try(local.combined_objects_container_registry[each.value.lz_key][each.value.container_registry_key].id, local.combined_objects_container_registry[local.client_config.landingzone_key][each.value.container_registry_key].id)
  base_tags               = try(local.global_settings.inherit_tags, false) ? local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].tags : {}

}

output "machine_learning_workspaces" {
  value = module.machine_learning_workspaces
}

module "machine_learning_compute_instance" {
  source   = "./modules/analytics/machine_learning_compute_instance"
  for_each = local.compute.machine_learning_compute_instance

  global_settings = local.global_settings
  client_config   = local.client_config
  settings        = each.value
  location        = can(local.global_settings.regions[each.value.region]) ? local.global_settings.regions[each.value.region] : local.combined_objects_resource_groups[try(each.value.resource_group.lz_key, local.client_config.landingzone_key)][try(each.value.resource_group.key, each.value.resource_group_key)].location

  remote_objects = {
    managed_identities            = local.combined_objects_managed_identities
    machine_learning_workspace_id = can(each.value.machine_learning_workspace.id) ? each.value.machine_learning_workspace.id : local.combined_objects_machine_learning[try(each.value.machine_learning_workspace.lz_key, local.client_config.landingzone_key)][each.value.machine_learning_workspace.key].id
    subnet_resource_id            = can(each.value.subnet.id) ? each.value.subnet.id : local.combined_objects_networking[try(each.value.subnet.lz_key, local.client_config.landingzone_key)][each.value.subnet.vnet_key].subnets[each.value.subnet.key].id
  }
}
output "machine_learning_compute_instance" {
  value = module.machine_learning_compute_instance
}