locals {
  per_origin_custom_rules = merge(flatten([
    for profile_name, profile_origins in local.frontdoor_profiles : [
      for origin_name, origin_values in profile_origins : {
        for name, rule in origin_values["waf_custom_rules"] : "${origin_name}:${name}" => rule
      } if length(origin_values["waf_custom_rules"]) > 0
    ]
  ])...)
}

resource "azurerm_cdn_frontdoor_firewall_policy" "waf" {
  for_each = local.enable_frontdoor ? local.frontdoor_profiles : {}

  name                = "${replace(local.environment, "/[^[:alnum:]]/", "")}${replace(each.key, "-", "")}waf"
  resource_group_name = local.resource_group.name
  sku_name            = azurerm_cdn_frontdoor_profile.rsd[each.key].sku_name
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
  for_each = local.enable_frontdoor && length(azurerm_cdn_frontdoor_endpoint.rsd) > 0 ? local.frontdoor_profiles : {}

  name                     = "${replace(local.environment, "/[^[:alnum:]]/", "-")}-${each.key}-global-policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[each.key].id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.waf[each.key].id

      association {
        dynamic "domain" {
          for_each = {
            for k, v in azurerm_cdn_frontdoor_custom_domain.rsd : k => v if element(split("/", v.cdn_frontdoor_profile_id), -1) == "${local.environment}-${each.key}"
          }

          content {
            cdn_frontdoor_domain_id = domain.value.id
          }
        }

        dynamic "domain" {
          for_each = {
            for k, v in azurerm_cdn_frontdoor_endpoint.rsd : k => v if element(split("/", v.cdn_frontdoor_profile_id), -1) == "${local.environment}-${each.key}"
          }

          content {
            cdn_frontdoor_domain_id = domain.value.id
          }
        }

        patterns_to_match = ["/*"]
      }
    }
  }
}
