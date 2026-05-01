resource "azurerm_cdn_frontdoor_rule_set" "vdp" {
  for_each = local.enable_frontdoor && local.enable_frontdoor_vdp_redirects ? local.frontdoor_profiles : {}

  name                     = "dfevdpredirects"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[each.key].id
}

resource "azurerm_cdn_frontdoor_rule" "vdp_security_txt" {
  for_each = local.enable_frontdoor && local.enable_frontdoor_vdp_redirects ? local.frontdoor_profiles : {}

  depends_on                = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]
  name                      = "securitytxtredirect"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.vdp[each.key].id
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
  for_each = local.enable_frontdoor && local.enable_frontdoor_vdp_redirects ? local.frontdoor_profiles : {}

  depends_on                = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]
  name                      = "thankstxtredirect"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.vdp[each.key].id
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
  for_each = local.enable_frontdoor && local.enable_frontdoor_vdp_redirects ? local.frontdoor_profiles : {}

  name                     = "enforcesecurityheaders"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[each.key].id
}

resource "azurerm_cdn_frontdoor_rule" "security" {
  for_each = local.enable_frontdoor && local.enable_frontdoor_vdp_redirects ? local.frontdoor_profiles : {}

  depends_on                = [azurerm_cdn_frontdoor_origin_group.rsd, azurerm_cdn_frontdoor_origin.rsd]
  name                      = "owasp"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.security[each.key].id
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
  for_each = local.enable_frontdoor ? merge([
    for profile_name, profile_origins in local.frontdoor_profiles : {
      for origin_name, origin_values in profile_origins : origin_name => merge({ profile_name = profile_name }, origin_values) if(length(origin_values["add_http_response_headers"]) > 0 || length(origin_values["remove_http_response_headers"]) > 0)
    }
  ]...) : {}

  name                     = "${replace(each.key, "/[^[:alnum:]]/", "")}responseheaders"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[each.value["profile_name"]].id
}

resource "azurerm_cdn_frontdoor_rule" "remove_response_headers" {
  for_each = local.enable_frontdoor ? merge([
    for profile_name, profile_origins in local.frontdoor_profiles : {
      for origin_name, origin_values in profile_origins : origin_name => origin_values["remove_http_response_headers"] if length(origin_values["remove_http_response_headers"]) > 0
    }
  ]...) : {}

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
  for_each = local.enable_frontdoor ? merge([
    for profile_name, profile_origins in local.frontdoor_profiles : {
      for origin_name, origin_values in profile_origins : origin_name => origin_values["add_http_response_headers"] if length(origin_values["add_http_response_headers"]) > 0
    }
  ]...) : {}

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
  for_each = local.enable_frontdoor && length(local.frontdoor_host_redirects) > 0 ? merge([
    for profile_name, profile_origins in local.frontdoor_profiles : {
      for origin_name, origin_values in profile_origins : origin_name => { profile_name = profile_name } if origin_values["redirects"] != null && length(origin_values["redirects"]) > 0
    }
  ]...) : {}

  name                     = "${replace(each.key, "/[^[:alnum:]]/", "")}hostredirects"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.rsd[each.value["profile_name"]].id
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

