data "azurerm_resource_group" "existing_resource_group" {
  count = local.existing_resource_group == "" ? 0 : 1

  name = local.existing_resource_group
}

data "azurerm_dns_zone" "zone" {
  for_each = local.custom_domains_dns_zones

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
}
