resource "azurerm_cdn_frontdoor_rule_set" "vdp" {
  count = local.enable_frontdoor && local.enable_frontdoor_vdp_redirects ? 1 : 0

  name                     = "dfevdpredirects"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[0].id
}

resource "azurerm_cdn_frontdoor_rule" "vdp_security_txt" {
  count = local.enable_frontdoor && local.enable_frontdoor_vdp_redirects ? 1 : 0

  depends_on                = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]
  name                      = "securitytxtredirect"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.vdp[0].id
  order                     = 1
  behavior_on_match         = "Continue"

  actions {
    url_redirect_action {
      redirect_type        = "PermanentRedirect"
      redirect_protocol    = "Https"
      destination_hostname = local.frontdoor_vdp_destination_hostname
      destination_path     = "/.well-known/security.txt"
    }
  }

  conditions {
    url_filename_condition {
      operator     = "Equal"
      match_values = ["security.txt", "/.well-known/security.txt"]
      transforms   = ["Lowercase", "RemoveNulls", "Trim"]
    }
  }
}

resource "azurerm_cdn_frontdoor_rule" "vdp_thanks_txt" {
  count = local.enable_frontdoor && local.enable_frontdoor_vdp_redirects ? 1 : 0

  depends_on                = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]
  name                      = "thankstxtredirect"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.vdp[0].id
  order                     = 2
  behavior_on_match         = "Continue"

  actions {
    url_redirect_action {
      redirect_type        = "PermanentRedirect"
      redirect_protocol    = "Https"
      destination_hostname = local.frontdoor_vdp_destination_hostname
      destination_path     = "/thanks.txt"
    }
  }

  conditions {
    url_filename_condition {
      operator     = "Equal"
      match_values = ["thanks.txt", "/.well-known/thanks.txt"]
      transforms   = ["Lowercase", "RemoveNulls", "Trim"]
    }
  }
}

resource "azurerm_cdn_frontdoor_rule_set" "security" {
  count = local.enable_frontdoor ? 1 : 0

  name                     = "enforcesecurityheaders"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[0].id
}

resource "azurerm_cdn_frontdoor_rule" "security" {
  count = local.enable_frontdoor ? 1 : 0

  depends_on                = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]
  name                      = "owasp"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.security[0].id
  order                     = 1
  behavior_on_match         = "Continue"

  actions {
    dynamic "response_header_action" {
      for_each = local.security_http_headers

      content {
        header_action = "Overwrite"
        header_name   = response_header_action.key
        value         = response_header_action.value
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_rule_set" "response_headers" {
  for_each = local.enable_frontdoor ? { for key, origin in local.frontdoor_origins : key => origin.add_http_response_headers if(length(origin.add_http_response_headers) > 0 || length(origin.remove_http_response_headers) > 0) } : {}

  name                     = "${replace(each.key, "/[^[:alnum:]]/", "")}responseheaders"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[0].id
}

resource "azurerm_cdn_frontdoor_rule" "remove_response_headers" {
  for_each = local.enable_frontdoor ? { for key, origin in local.frontdoor_origins : key => origin.remove_http_response_headers if length(origin.remove_http_response_headers) > 0 } : {}

  depends_on = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]

  name                      = "removeheaders"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.response_headers[each.key].id
  order                     = 1
  behavior_on_match         = "Continue"

  actions {
    dynamic "response_header_action" {
      for_each = each.value

      content {
        header_action = "Delete"
        header_name   = response_header_action.value.name
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_rule" "add_response_headers" {
  for_each = local.enable_frontdoor ? { for key, origin in local.frontdoor_origins : key => origin.add_http_response_headers if length(origin.add_http_response_headers) > 0 } : {}

  depends_on = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]

  name                      = "addheaders"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.response_headers[each.key].id
  order                     = 2
  behavior_on_match         = "Continue"

  actions {
    dynamic "response_header_action" {
      for_each = each.value

      content {
        header_action = "Overwrite"
        header_name   = response_header_action.value.name
        value         = response_header_action.value.value
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_rule_set" "host_redirects" {
  for_each = local.enable_frontdoor && length(local.frontdoor_host_redirects) > 0 ? local.frontdoor_host_redirects : {}

  name                     = "${replace(each.key, "/[^[:alnum:]]/", "")}hostredirects"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[0].id
}

resource "azurerm_cdn_frontdoor_rule" "host_redirects" {
  for_each = local.enable_frontdoor && length(local.frontdoor_host_redirects) > 0 ? {
    for rule in flatten([
      for key, redirects in local.frontdoor_host_redirects : [
        for redirect in redirects : {
          order  = index(redirects, redirect) + 1
          origin = key
          from   = redirect.from
          to     = redirect.to
        }
      ]
    ]) : "${rule.origin}-${replace(rule.from, "/[^[:alnum:]]/", "-")}" => rule
  } : {}

  depends_on = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]

  name                      = replace(each.key, "/[^[:alnum:]]/", "")
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.host_redirects[each.value.origin].id
  order                     = each.value.order
  behavior_on_match         = "Continue"

  actions {
    url_redirect_action {
      redirect_type        = "Moved"
      redirect_protocol    = "Https"
      destination_hostname = each.value.to
    }
  }

  conditions {
    host_name_condition {
      operator         = "Equal"
      negate_condition = false
      match_values     = [each.value.from]
      transforms       = ["Lowercase", "Trim"]
    }
  }
}

/**
 * This rule set is temporarily added until the .NET rewrite takes over all traffic from the Ruby app
 * - Ash Davies 27/01/2025
 */
resource "azurerm_cdn_frontdoor_rule_set" "complete_dotnet_ruby_migration" {
  count = local.enable_frontdoor ? 1 : 0

  name                     = "completedotnetreroute"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[0].id
}

resource "azurerm_cdn_frontdoor_rule" "dotnet_disable_override" {
  /* If reversing the front door, don't include this rule */
  count      = local.enable_custom_reroute_reversal == true ? 0 : 1
  depends_on = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]

  name                      = "dotnetdisableoverride"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.complete_dotnet_ruby_migration[0].id
  order                     = 1
  behavior_on_match         = "Stop"

  conditions {
    cookies_condition {
      cookie_name = "dotnet-disable"
      operator    = "Any"
    }
  }

  actions {
    response_header_action {
      header_action = "Append"
      header_name   = "X-Backend-Origin-Rerouted"
      value         = "ruby"
    }
  }
}

resource "azurerm_cdn_frontdoor_rule" "dotnet_disable_override_reverse" {
  /* If reversing the front door, include this rule */
  count      = local.enable_custom_reroute_reversal == true ? 1 : 0
  depends_on = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]

  name                      = "dotnetdisableoverridereverse"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.complete_dotnet_ruby_migration[0].id
  order                     = 1
  behavior_on_match         = "Stop"

  conditions {
    cookies_condition {
      cookie_name = "dotnet-disable"
      operator    = "Any"
    }
  }

  actions {
    response_header_action {
      header_action = "Append"
      header_name   = "X-Backend-Origin-Rerouted"
      value         = "ruby"
    }

    route_configuration_override_action {
      cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.rsd["complete-ruby"].id
      forwarding_protocol           = azurerm_cdn_frontdoor_route.rsd["complete-ruby"].forwarding_protocol
      cache_behavior                = "Disabled"
    }
  }
}

resource "azurerm_cdn_frontdoor_rule" "complete_dotnet_ruby_migration" {
  for_each = local.complete_dotnet_ruby_migration_paths

  depends_on = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]

  name                      = "rerouteorigin${each.key}"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.complete_dotnet_ruby_migration[0].id
  order                     = each.value.order
  behavior_on_match         = lookup(each.value, "behavior_on_match", "Continue")

  actions {
    route_configuration_override_action {
      cdn_frontdoor_origin_group_id = local.enable_custom_reroute_reversal ? azurerm_cdn_frontdoor_origin_group.rsd["complete-ruby"].id : azurerm_cdn_frontdoor_origin_group.rsd["complete-dotnet"].id
      forwarding_protocol           = local.enable_custom_reroute_reversal ? azurerm_cdn_frontdoor_route.rsd["complete-ruby"].forwarding_protocol : azurerm_cdn_frontdoor_route.rsd["complete-dotnet"].forwarding_protocol
      cache_behavior                = "Disabled"
    }

    response_header_action {
      header_action = "Append"
      header_name   = "X-Backend-Origin-Rerouted"
      value         = local.enable_custom_reroute_reversal ? "ruby" : "dotnet"
    }

    dynamic "request_header_action" {
      for_each = lookup(each.value, "append_request_headers", {})

      content {
        header_action = "Append"
        header_name   = request_header_action.key
        value         = request_header_action.value
      }
    }
  }

  conditions {
    url_path_condition {
      match_values = each.value.routes
      operator     = lookup(each.value, "operator", "BeginsWith")
    }

    dynamic "cookies_condition" {
      for_each = lookup(each.value, "require_cookie", false) && local.enable_custom_reroute_reversal != true ? [1] : []

      content {
        cookie_name = "dotnet-bypass"
        operator    = "Any"
      }
    }

    dynamic "cookies_condition" {
      for_each = lookup(each.value, "require_cookie", false) && local.enable_custom_reroute_reversal == true ? [1] : []

      content {
        cookie_name = "dotnet-bypass"
        operator    = "Not Any"
      }
    }

    dynamic "request_header_condition" {
      for_each = length(lookup(each.value, "require_header", {})) > 0 ? [1] : []

      content {
        header_name  = each.value.require_header.name
        operator     = lookup(each.value.require_header, "operator", "Equal")
        match_values = each.value.require_header.values
      }
    }
  }
}
