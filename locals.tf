locals {
  environment                        = var.environment
  azure_location                     = var.azure_location
  tags                               = var.tags
  existing_resource_group            = var.existing_resource_group
  resource_group                     = local.existing_resource_group == "" ? azurerm_resource_group.rsd_frontdoor[0] : data.azurerm_resource_group.existing_resource_group[0]
  enable_resource_group_lock         = var.enable_resource_group_lock
  enable_frontdoor                   = var.enable_frontdoor
  frontdoor_sku                      = var.frontdoor_sku
  frontdoor_response_timeout         = var.frontdoor_response_timeout
  frontdoor_origins                  = var.frontdoor_origins
  enable_frontdoor_vdp_redirects     = var.enable_frontdoor_vdp_redirects
  frontdoor_vdp_destination_hostname = var.frontdoor_vdp_destination_hostname
  security_http_headers = {
    "Strict-Transport-Security" = "max-age=31536000; includeSubDomains; preload"
    "X-Xss-Protection"          = "0"
    "X-Frame-Options"           = "DENY"
    "X-Content-Type-Options"    = "nosniff"
  }
}
