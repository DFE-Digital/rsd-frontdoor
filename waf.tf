locals {
  per_origin_custom_rules = merge([
    for key, origin in local.frontdoor_origins : {
      for name, rule in origin.waf_custom_rules : "${key}:${name}" => rule
    } if length(origin.waf_custom_rules) > 0
  ]...)
}

resource "azurerm_cdn_frontdoor_firewall_policy" "waf" {
  count = local.enable_frontdoor ? 1 : 0

  name                = "${replace(local.environment, "/[^[:alnum:]]/", "")}rsdfrontdoorwaf"
  resource_group_name = local.resource_group.name
  sku_name            = azurerm_cdn_frontdoor_profile.rsd[0].sku_name
  enabled             = local.enable_frontdoor_waf
  mode                = local.waf_mode

  dynamic "managed_rule" {
    for_each = local.waf_enable_bot_protection ? [1] : []

    content {
      type    = "Microsoft_BotManagerRuleSet"
      version = "1.1"
      action  = "Block"
    }
  }

  dynamic "custom_rule" {
    for_each = local.per_origin_custom_rules

    content {
      name     = replace(custom_rule.key, "/[^[:alnum:]]/", "")
      enabled  = true
      priority = index(tolist(keys(local.per_origin_custom_rules)), custom_rule.key) + 1
      type     = "MatchRule"
      action   = custom_rule.value["action"]

      match_condition {
        match_variable = "RequestHeader"
        selector       = "Host"
        operator       = "Equal"
        match_values = concat([
          azurerm_cdn_frontdoor_endpoint.rsd[split(":", custom_rule.key)[0]].host_name,
          ], [
          for domain in local.frontdoor_custom_domain_map : domain.hostname if domain.origin_key == split(":", custom_rule.key)[0]
        ])
      }

      dynamic "match_condition" {
        for_each = custom_rule.value["match_conditions"]

        content {
          match_variable     = match_condition.value["match_variable"]
          match_values       = match_condition.value["match_values"]
          operator           = match_condition.value["operator"]
          selector           = match_condition.value["selector"]
          negation_condition = match_condition.value["negation_condition"]
        }
      }
    }
  }

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


  tags = local.tags
}


resource "azurerm_cdn_frontdoor_security_policy" "waf" {
  count = local.enable_frontdoor && length(azurerm_cdn_frontdoor_endpoint.rsd) > 0 ? 1 : 0

  name                     = "${replace(local.environment, "/[^[:alnum:]]/", "-")}-rsd-frontdoor-global-policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[0].id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf[0].id

      association {
        dynamic "domain" {
          for_each = azurerm_cdn_frontdoor_custom_domain.rsd

          content {
            cdn_frontdoor_domain_id = domain.value.id
          }
        }

        dynamic "domain" {
          for_each = azurerm_cdn_frontdoor_endpoint.rsd

          content {
            cdn_frontdoor_domain_id = domain.value.id
          }
        }

        patterns_to_match = ["/*"]
      }
    }
  }
}
