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
