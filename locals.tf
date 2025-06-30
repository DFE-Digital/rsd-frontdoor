locals {
  environment                    = var.environment
  azure_environment              = strcontains(local.environment, "d") ? "development" : strcontains(local.environment, "t") ? "test" : strcontains(local.environment, "p") ? "production" : ""
  azure_location                 = var.azure_location
  tags                           = var.tags
  existing_resource_group        = var.existing_resource_group
  resource_group                 = local.existing_resource_group == "" ? azurerm_resource_group.rsd_frontdoor[0] : data.azurerm_resource_group.existing_resource_group[0]
  enable_resource_group_lock     = var.enable_resource_group_lock
  key_vault_access_ipv4          = var.key_vault_access_ipv4
  tfvars_filename                = var.tfvars_filename
  enable_frontdoor               = var.enable_frontdoor
  frontdoor_sku                  = var.frontdoor_sku
  frontdoor_response_timeout     = var.frontdoor_response_timeout
  frontdoor_origins              = var.frontdoor_origins
  enable_frontdoor_vdp_redirects = var.enable_frontdoor_vdp_redirects
  frontdoor_host_redirects = {
    for k, v in local.frontdoor_origins : k => v["redirects"] if v["redirects"] != null && length(v["redirects"]) > 0
  }
  frontdoor_vdp_destination_hostname = var.frontdoor_vdp_destination_hostname
  security_http_headers = {
    "Strict-Transport-Security" = "max-age=31536000; includeSubDomains; preload"
    "X-Xss-Protection"          = "0"
    "X-Frame-Options"           = "DENY"
    "X-Content-Type-Options"    = "nosniff"
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


  enable_custom_reroute_ruleset = var.enable_custom_reroute_ruleset
  complete_dotnet_ruby_migration_paths_development = {
    "cookies" : {
      order : 10,
      behavior_on_match : "Stop",
      require_cookie : false,
      require_header : {
        name : "Content-Type",
        values : [
          "application/x-www-form-urlencoded"
        ]
      },
      append_request_headers : {
        "x-request-origin" : "ruby"
      },
      routes : [
        "cookies"
      ]
    },
    "assets" : {
      order : 20,
      require_cookie : false,
      routes : [
        "dist",
        "signin-oidc",
        "netassets",
        "accessibility",
        "cookies"
      ]
    },
    "search" : {
      order : 30,
      require_cookie : false,
      routes : [
        "^search(?:\\?(?:[^\\/#]*))?$",
      ],
      operator : "RegEx"
    },
    "projects" : {
      order : 40,
      require_cookie : false,
      routes : [
        "projects/all/by-month",
        "projects/all/completed",
        "projects/all/in-progress",
        "projects/all/local-authorities",
        "projects/all/regions",
        "projects/all/trusts",
        "projects/all/users",
        "projects/team",
        "projects/yours",
      ]
    }
  }
  complete_dotnet_ruby_migration_paths_test = {
    "cookies" : {
      order : 10,
      behavior_on_match : "Stop",
      require_cookie : false,
      require_header : {
        name : "Content-Type",
        values : [
          "application/x-www-form-urlencoded"
        ]
      },
      append_request_headers : {
        "x-request-origin" : "ruby"
      },
      routes : [
        "cookies"
      ]
    },
    "assets" : {
      order : 20,
      require_cookie : false,
      routes : [
        "dist",
        "signin-oidc",
        "netassets",
        "accessibility",
        "cookies"
      ]
    },
    "search" : {
      order : 30,
      require_cookie : false,
      routes : [
        "^search(?:\\?(?:[^\\/#]*))?$",
      ],
      operator : "RegEx"
    },
    "projects" : {
      order : 40,
      require_cookie : false,
      routes : [
        "projects/all/by-month",
        "projects/all/completed",
        "projects/all/in-progress",
        "projects/all/local-authorities",
        "projects/all/regions",
        "projects/all/trusts",
        "projects/all/users",
        "projects/team",
        "projects/yours",
      ]
    }
  }
  complete_dotnet_ruby_migration_paths_production = {
    "cookies" : {
      order : 10,
      behavior_on_match : "Stop",
      require_cookie : true,
      require_header : {
        name : "Content-Type",
        values : [
          "application/x-www-form-urlencoded"
        ]
      },
      append_request_headers : {
        "x-request-origin" : "ruby"
      },
      routes : [
        "cookies"
      ]
    },
    "assets" : {
      order : 20,
      require_cookie : true,
      routes : [
        "dist",
        "signin-oidc",
        "netassets",
        "accessibility",
        "cookies"
      ]
    },
    "search" : {
      order : 30,
      require_cookie : true,
      routes : [
        "^search(?:\\?(?:[^\\/#]*))?$",
      ],
      operator : "RegEx"
    },
    "projects" : {
      order : 40,
      require_cookie : true,
      routes : [
        "projects/all/in-progress/all",
      ]
    }
  }

  complete_dotnet_ruby_migration_all = {
    development = local.complete_dotnet_ruby_migration_paths_development
    test        = local.complete_dotnet_ruby_migration_paths_test
    production  = local.complete_dotnet_ruby_migration_paths_production
  }

  complete_dotnet_ruby_migration_paths = lookup(local.complete_dotnet_ruby_migration_all, local.azure_environment, {})
}
