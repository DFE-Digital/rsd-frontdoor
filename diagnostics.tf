resource "azurerm_log_analytics_workspace" "diagnostics" {
  count = local.enable_frontdoor ? 1 : 0

  name                = "${azurerm_cdn_frontdoor_profile.rsd[0].name}-logs"
  resource_group_name = local.resource_group.name
  location            = local.resource_group.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "cdn" {
  count = local.enable_frontdoor ? 1 : 0

  name                       = "${azurerm_cdn_frontdoor_profile.rsd[0].name}-diagnostics"
  target_resource_id         = azurerm_cdn_frontdoor_profile.rsd[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.diagnostics[0].id

  dynamic "enabled_log" {
    for_each = local.frontdoor_enable_waf_logs ? [1] : []

    content {
      category = "FrontdoorWebApplicationFirewallLog"
    }
  }

  dynamic "enabled_log" {
    for_each = local.frontdoor_enable_access_logs ? [1] : []

    content {
      category = "FrontdoorAccessLog"
    }
  }

  dynamic "enabled_log" {
    for_each = local.frontdoor_enable_health_probe_logs ? [1] : []

    content {
      category = "FrontdoorHealthProbeLog"
    }
  }

  # The below metrics are kept in to avoid a diff in the Terraform Plan output
  metric {
    category = "AllMetrics"
    enabled  = false
  }
}
