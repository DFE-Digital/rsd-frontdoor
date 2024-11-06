resource "azurerm_resource_group" "rsd_frontdoor" {
  count = local.existing_resource_group == "" ? 1 : 0

  name     = "${local.environment}-rsd-frontdoor"
  location = local.azure_location
  tags     = local.tags
}

resource "azurerm_management_lock" "rsd_frontdoor" {
  count = local.enable_resource_group_lock ? 1 : 0

  name       = "${local.environment}-rsd-frontdoor-lock"
  scope      = local.resource_group.id
  lock_level = "CanNotDelete"
  notes      = "Resources in this Resource Group cannot be deleted. Please remove the lock first."
}
