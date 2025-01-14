resource "azurerm_cdn_frontdoor_profile" "rsd" {
  count = local.enable_frontdoor ? 1 : 0

  name                     = "${local.environment}-rsd-frontdoor"
  resource_group_name      = local.resource_group.name
  sku_name                 = local.frontdoor_sku
  response_timeout_seconds = local.frontdoor_response_timeout
  tags                     = local.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "rsd" {
  for_each = local.frontdoor_origins

  name                     = "${local.environment}-rsd-frontdoor-${each.key}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[0].id

  load_balancing {}

  dynamic "health_probe" {
    for_each = each.value["enable_health_probe"] ? [1] : []

    content {
      protocol            = "Https"
      interval_in_seconds = each.value["health_probe_interval"]
      request_type        = each.value["health_probe_request_type"]
      path                = each.value["health_probe_path"]
    }
  }
}

resource "azurerm_cdn_frontdoor_origin" "rsd" {
  for_each = local.frontdoor_origins

  name                           = "${local.environment}-rsd-frontdoor-${each.key}"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.rsd[each.key].id
  enabled                        = true
  certificate_name_check_enabled = true
  host_name                      = each.value["origin_host"]
  origin_host_header             = each.value["origin_host_header"] != null ? each.value["origin_host_header"] : each.value["origin_host"]
  http_port                      = 80
  https_port                     = 443

  dynamic "private_link" {
    for_each = each.value["private_link_target_id"] != null ? [1] : []

    content {
      request_message        = "Request access for Private Link from RSD FrontDoor CDN Origin (${local.environment}-rsd-frontdoor-${each.key})"
      location               = local.azure_location
      private_link_target_id = each.value["private_link_target_id"]
    }
  }
}

resource "azurerm_cdn_frontdoor_endpoint" "rsd" {
  for_each = local.frontdoor_origins

  name                     = substr("${local.environment}-rsd-frontdoor-${each.key}", 0, 46)
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[0].id

  tags = local.tags
}

resource "azurerm_cdn_frontdoor_custom_domain" "rsd" {
  for_each = toset(flatten([
    for v in local.frontdoor_origins : [
      for custom_domain in v.custom_domains : custom_domain
    ]
  ]))

  name                     = "${local.environment}-rsd-frontdoor-${each.value}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[0].id
  host_name                = each.value

  tls {
    certificate_type    = "ManagedCertificate"
    minimum_tls_version = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_route" "rsd" {
  for_each = local.frontdoor_origins

  name                          = "${local.environment}-rsd-frontdoor-${each.key}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.rsd[each.key].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.rsd[each.key].id
  cdn_frontdoor_rule_set_ids = compact([
    local.enable_frontdoor_vdp_redirects ? azurerm_cdn_frontdoor_rule_set.vdp[0].id : null,
    each.value.enable_security_headers ? azurerm_cdn_frontdoor_rule_set.security[0].id : null,
  ])
  cdn_frontdoor_origin_ids = [
    azurerm_cdn_frontdoor_origin.rsd[each.key].id
  ]

  enabled                = true
  forwarding_protocol    = each.value["forwarding_protocol"]
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cdn_frontdoor_custom_domain_ids = [
    for domain in each.value["custom_domains"] : azurerm_cdn_frontdoor_custom_domain.rsd[domain].id
  ]

  link_to_default_domain = true
}
