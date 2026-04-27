locals {
  environment                    = var.environment
  azure_location                 = var.azure_location
  tags                           = var.tags
  existing_resource_group        = var.existing_resource_group
  resource_group                 = local.existing_resource_group == "" ? azurerm_resource_group.rsd_frontdoor[0] : data.azurerm_resource_group.existing_resource_group[0]
  enable_resource_group_lock     = var.enable_resource_group_lock
  tfvars_filename                = var.tfvars_filename
  enable_frontdoor               = var.enable_frontdoor
  frontdoor_sku                  = var.frontdoor_sku
  frontdoor_response_timeout     = var.frontdoor_response_timeout
  frontdoor_profiles             = var.frontdoor_profiles
  enable_frontdoor_vdp_redirects = var.enable_frontdoor_vdp_redirects
  frontdoor_host_redirects = merge([
    for profile_name, profile_origins in local.frontdoor_profiles : {
      for origin_name, origin_values in profile_origins : origin_name => origin_values["redirects"] if origin_values["redirects"] != null && length(origin_values["redirects"]) > 0
    }
  ]...)

  frontdoor_vdp_destination_hostname = var.frontdoor_vdp_destination_hostname
  security_http_headers = {
    "Strict-Transport-Security" = "max-age=31536000; includeSubDomains; preload"
    "X-Xss-Protection"          = "0"
    "X-Frame-Options"           = "DENY"
    "X-Content-Type-Options"    = "nosniff"
  }
  custom_domains = flatten([
    for profile_name, profile_origins in local.frontdoor_profiles : [
      for origin_key, origin in profile_origins : [
        for domain in origin.custom_domains : {
          origin_key   = origin_key
          hostname     = domain
          zone_name    = one([for z in origin.managed_dns_zones : z.name if strcontains(domain, z.name)])
          profile_name = profile_name
        }
      ]
    ]
  ])
  custom_domains_dns_zones = {
    for zone in distinct(flatten([
      for profile_name, profile_origins in local.frontdoor_profiles : [
        for origin_name, origin_values in profile_origins : origin_values["managed_dns_zones"]
      ]
    ])) : zone.name => zone
  }
  frontdoor_custom_domain_map = {
    for domain_info in local.custom_domains :
    "${domain_info.origin_key}:${domain_info.hostname}" => {
      name         = replace("${domain_info.origin_key}:${domain_info.hostname}", "/[^[:alnum:]]/", "-")
      hostname     = domain_info.hostname
      origin_key   = domain_info.origin_key
      dns_zone_id  = domain_info.zone_name != null ? try(data.azurerm_dns_zone.zone[domain_info.zone_name].id, null) : null
      profile_name = domain_info.profile_name
    }
  }
  frontdoor_enable_access_logs          = var.frontdoor_enable_access_logs
  frontdoor_enable_health_probe_logs    = var.frontdoor_enable_health_probe_logs
  frontdoor_enable_waf_logs             = var.frontdoor_enable_waf_logs
  enable_frontdoor_waf                  = var.enable_frontdoor_waf
  waf_mode                              = var.waf_mode
  waf_enable_bot_protection             = var.waf_enable_bot_protection
  waf_enable_rate_limiting              = var.waf_enable_rate_limiting
  waf_rate_limiting_duration_in_minutes = var.waf_rate_limiting_duration_in_minutes
  waf_rate_limiting_threshold           = var.waf_rate_limiting_threshold
  waf_rate_limiting_bypass_ip_list      = var.waf_rate_limiting_bypass_ip_list

  is_windows = can(regex("^[A-Za-z]:", abspath(path.root)))
  bash       = local.is_windows ? "C:/Program Files/Git/bin/bash.exe" : "/bin/bash"
}
