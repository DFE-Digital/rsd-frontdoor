resource "azurerm_cdn_frontdoor_firewall_policy" "waf" {
  count = local.enable_frontdoor ? 1 : 0

  name                = "${replace(local.environment, "/[^[:alnum:]]/", "-")}rsdfrontdoorwaf"
  resource_group_name = local.resource_group.name
  sku_name            = azurerm_cdn_frontdoor_profile.rsd[0].sku_name
  enabled             = local.enable_frontdoor_waf
  mode                = local.waf_mode

  dynamic "custom_rule" {
    for_each = local.waf_enable_rate_limiting ? [1] : []

    content {
      name                           = "RateLimiting"
      enabled                        = true
      priority                       = 1000
      rate_limit_duration_in_minutes = local.waf_rate_limiting_duration_in_minutes
      rate_limit_threshold           = local.waf_rate_limiting_threshold
      type                           = "RateLimitRule"
      action                         = "Block"

      dynamic "match_condition" {
        for_each = length(local.waf_rate_limiting_bypass_ip_list) > 0 ? [0] : []

        content {
          match_variable     = "RemoteAddr"
          operator           = "IPMatch"
          negation_condition = true
          match_values       = local.waf_rate_limiting_bypass_ip_list
        }
      }

      match_condition {
        match_variable     = "RequestUri"
        operator           = "Any"
        negation_condition = false
        match_values       = []
      }
    }
  }

  dynamic "managed_rule" {
    for_each = local.waf_enable_bot_protection ? [1] : []

    content {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.1"
      action  = "Block"
    }
  }

  tags = local.tags
}
