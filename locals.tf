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
  custom_domains = flatten([
    for origin_key, origin in var.frontdoor_origins : [
      for domain in origin.custom_domains : {
        origin_key = origin_key
        hostname   = domain
        zone_name  = one([for z in origin.managed_dns_zones : z.name if strcontains(domain, z.name)])
      }
    ]
  ])
  custom_domains_dns_zones = {
    for zone in distinct(flatten([
      for origin in var.frontdoor_origins : origin.managed_dns_zones
    ])) : zone.name => zone
  }
  frontdoor_custom_domain_map = {
    for domain_info in local.custom_domains :
    "${domain_info.origin_key}:${domain_info.hostname}" => {
      name        = replace("${domain_info.origin_key}:${domain_info.hostname}", "/[^[:alnum:]]/", "-")
      hostname    = domain_info.hostname
      origin_key  = domain_info.origin_key
      dns_zone_id = domain_info.zone_name != null ? try(data.azurerm_dns_zone.zone[domain_info.zone_name].id, null) : null
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


  enable_custom_reroute_ruleset  = var.enable_custom_reroute_ruleset
  enable_custom_reroute_reversal = var.enable_custom_reroute_reversal
  complete_dotnet_project_prefix = "^projects/[^/]+"

  complete_dotnet_ruby_migration_paths_development = {
    "rubyauth" : {
      order : 10,
      require_cookie : false,
      routes : [
        "/auth/:provider/callback",
        "/auth/failure",
        "/auth/azure_activedirectory_v2",
        "/sign-in",
        "/sign-out"
      ]
    },
    "exports" : {
      order : 20,
      require_cookie : false,
      routes : [
        "/projects/all/export/by-significant-date/"
      ]
    },
    "projectpage" : {
      order : 30,
      require_cookie : false,
      routes : [
        "${local.complete_dotnet_project_prefix}/confirm_delete",
      ],
      operator : "RegEx",
    },
    "projecttasksgroupone" : {
      order : 40,
      require_cookie : false,
      routes : [
        "/tasks/conversion_grant",
        "/tasks/sponsored_support_grant",
        "/tasks/confirm_chair_of_governors_contact",
        "/tasks/trust_modification_order",
        "/tasks/direction_to_transfer",
        "/tasks/one_hundred_and_twenty_five_year_lease",
        "/tasks/subleases",
        "/tasks/tenancy_at_will",
        "/tasks/school_completed",
        "/tasks/share_information"
      ],
      operator : "EndsWith",
    },
    "projecttasksgrouptwo" : {
      order : 50,
      require_cookie : false,
      routes : [
        "/tasks/confirm_outgoing_trust_ceo_contact",
        "/tasks/request_new_urn_and_record",
        "/tasks/form_m",
        "/tasks/closure_or_transfer_declaration",
        "/tasks/confirm_incoming_trust_has_completed_all_actions"
      ],
      operator : "EndsWith",
    },
    "rubyapi" : {
      order : 60,
      require_cookie : false,
      routes : [
        "/api"
      ],
    },
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
        "cookies",
        "access-denied",
        "privacy",
      ]
    },
    "search" : {
      order : 30,
      require_cookie : false,
      routes : [
        "^search(?:/user)?(?:\\?[^/#]*)?$"
      ],
      operator : "RegEx"
    },
    "projects" : {
      order : 40,
      require_cookie : false,
      routes : [
        "projects/team",
        "projects/yours",
      ]
    },
    "allprojects" : {
      order : 50,
      require_cookie : false,
      routes : [
        "projects/all/by-month",
        "projects/all/completed",
        "projects/all/in-progress",
        "projects/all/local-authorities",
        "projects/all/regions",
        "projects/all/trusts",
        "projects/all/users",
        "projects/all/statistics",
        "projects/all/handover",
      ]
    },
    "servicesupport" : {
      order : 60,
      require_cookie : false,
      routes : [
        "projects/service-support/with-academy-urn",
        "projects/service-support/without-academy-urn",
        "service-support/local-authorities",
      ]
    },
    "servicesupportcreateurns" : {
      order : 70,
      require_cookie : false,
      routes : [
        "${local.complete_dotnet_project_prefix}/academy-urn",
      ],
      operator : "RegEx"
    },
    "exports" : {
      order : 80,
      require_cookie : false,
      routes : [
        "projects/all/export",
        "projects/all/reports",
      ],
      operator : "Equal"
    },
    "groups" : {
      order : 90,
      require_cookie : false,
      routes : [
        "groups",
      ]
    },
    "projectpage" : {
      order : 100,
      require_cookie : false,
      routes : [
        "${local.complete_dotnet_project_prefix}/(?:(?:information|notes|external-contacts|internal-contacts|date-history|dao-revocation|complete)(?:/.*)?|tasks)$",
      ],
      operator : "RegEx",
    },
    "editaboutproject" : {
      order : 110,
      require_cookie : false,
      routes : [
        "^projects/(?:conversions|transfers)/[^/]+(?:/.*)?(?:#.*)?$",
      ],
      operator : "RegEx",
    },
    "projecttasksgroupone" : {
      order : 120,
      require_cookie : false,
      routes : [
        "/tasks/handover",
        "/tasks/stakeholder_kick_off",
        "/tasks/proposed_capacity_of_the_academy",
        "/tasks/supplemental_funding_agreement",
        "/tasks/articles_of_association",
        "/tasks/deed_of_variation",
        "/tasks/conditions_met",
        "/tasks/redact_and_send",
        "/tasks/redact_and_send_documents",
        "/tasks/receive_grant_payment_certificate"
      ],
      operator : "EndsWith",
    },
    "projecttasksgrouptwo" : {
      order : 130,
      require_cookie : false,
      routes : [
        "/tasks/declaration_of_expenditure_certificate",
        "/tasks/deed_of_novation_and_variation",
        "/tasks/confirm_date_academy_opened",
        "/tasks/confirm_date_academy_transferred",
        "/tasks/church_supplemental_agreement",
        "/tasks/commercial_transfer_agreement",
        "/tasks/main_contact",
        "/tasks/land_questionnaire",
        "/tasks/land_registry",
        "/tasks/master_funding_agreement"
      ],
      operator : "EndsWith",
    },
    "projecttasksgroupthree" : {
      order : 140,
      require_cookie : false,
      routes : [
        "/tasks/confirm_incoming_trust_ceo_contact",
        "/tasks/risk_protection_arrangement",
        "/tasks/rpa_policy",
        "/tasks/confirm_headteacher_contact",
        "/tasks/check_and_confirm_financial_information",
        "/tasks/bank_details_changing",
        "/tasks/academy_details",
        "/tasks/complete_notification_of_change",
        "/tasks/check_accuracy_of_higher_needs",
        "/tasks/land_consent_letter",
      ],
      operator : "EndsWith",
    },
    "projecttasksgroupfour" : {
      order : 150,
      require_cookie : false,
      routes : [
        "/tasks/deed_termination_church_agreement",
        "/tasks/deed_of_termination_for_the_master_funding_agreement"
      ],
      operator : "EndsWith",
    },
    "formamattrust" : {
      order : 160,
      require_cookie : false,
      routes : [
        "form-a-multi-academy-trust/",
      ],
    },
    "servicesupportusersprerelease" : {
      order : 170,
      require_cookie : true,
      routes : [
        "service-support/users",
      ]
    },
    "confirmdeleteprerelease" : {
      order : 180,
      require_cookie : true,
      routes : [
        "${local.complete_dotnet_project_prefix}/confirm_delete",
      ],
      operator : "RegEx",
    },
  }
  complete_dotnet_ruby_migration_paths_production = {
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
        "cookies",
        "access-denied",
        "privacy",
      ]
    },
    "search" : {
      order : 30,
      require_cookie : false,
      routes : [
        "^search(?:/user)?(?:\\?[^/#]*)?$"
      ],
      operator : "RegEx"
    },
    "projects" : {
      order : 40,
      require_cookie : false,
      routes : [
        "projects/team",
        "projects/yours",
      ]
    },
    "allprojects" : {
      order : 50,
      require_cookie : false,
      routes : [
        "projects/all/by-month",
        "projects/all/completed",
        "projects/all/in-progress",
        "projects/all/local-authorities",
        "projects/all/regions",
        "projects/all/trusts",
        "projects/all/users",
        "projects/all/statistics",
        "projects/all/handover",
      ]
    },
    "servicesupport" : {
      order : 60,
      require_cookie : false,
      routes : [
        "projects/service-support/with-academy-urn",
        "projects/service-support/without-academy-urn",
        "service-support/local-authorities",
      ]
    },
    "servicesupportcreateurns" : {
      order : 70,
      require_cookie : false,
      routes : [
        "${local.complete_dotnet_project_prefix}/academy-urn",
      ],
      operator : "RegEx"
    },
    "exports" : {
      order : 80,
      require_cookie : false,
      routes : [
        "projects/all/export",
        "projects/all/reports",
      ],
      operator : "Equal"
    },
    "groups" : {
      order : 90,
      require_cookie : false,
      routes : [
        "groups",
      ]
    },
    "projectpage" : {
      order : 100,
      require_cookie : false,
      routes : [
        "${local.complete_dotnet_project_prefix}/(?:(?:information|notes|external-contacts|internal-contacts|date-history|dao-revocation|complete)(?:/.*)?|tasks)$",
      ],
      operator : "RegEx",
    },
    "editaboutproject" : {
      order : 110,
      require_cookie : false,
      routes : [
        "^projects/(?:conversions|transfers)/[^/]+(?:/.*)?(?:#.*)?$",
      ],
      operator : "RegEx",
    },
    "projecttasksgroupone" : {
      order : 120,
      require_cookie : false,
      routes : [
        "/tasks/handover",
        "/tasks/stakeholder_kick_off",
        "/tasks/proposed_capacity_of_the_academy",
        "/tasks/supplemental_funding_agreement",
        "/tasks/articles_of_association",
        "/tasks/deed_of_variation",
        "/tasks/conditions_met",
        "/tasks/redact_and_send",
        "/tasks/redact_and_send_documents",
        "/tasks/receive_grant_payment_certificate"
      ],
      operator : "EndsWith",
    },
    "projecttasksgrouptwo" : {
      order : 130,
      require_cookie : false,
      routes : [
        "/tasks/declaration_of_expenditure_certificate",
        "/tasks/deed_of_novation_and_variation",
        "/tasks/confirm_date_academy_opened",
        "/tasks/confirm_date_academy_transferred",
        "/tasks/church_supplemental_agreement",
        "/tasks/commercial_transfer_agreement",
        "/tasks/main_contact",
        "/tasks/land_questionnaire",
        "/tasks/land_registry",
        "/tasks/master_funding_agreement"
      ],
      operator : "EndsWith",
    },
    "projecttasksgroupthree" : {
      order : 140,
      require_cookie : false,
      routes : [
        "/tasks/confirm_incoming_trust_ceo_contact",
        "/tasks/risk_protection_arrangement",
        "/tasks/rpa_policy",
        "/tasks/confirm_headteacher_contact",
        "/tasks/check_and_confirm_financial_information",
        "/tasks/bank_details_changing",
        "/tasks/academy_details",
        "/tasks/complete_notification_of_change",
        "/tasks/check_accuracy_of_higher_needs",
        "/tasks/land_consent_letter",
      ],
      operator : "EndsWith",
    },
    "projecttasksgroupfour" : {
      order : 150,
      require_cookie : false,
      routes : [
        "/tasks/deed_termination_church_agreement",
        "/tasks/deed_of_termination_for_the_master_funding_agreement"
      ],
      operator : "EndsWith",
    },
    "formamattrust" : {
      order : 160,
      require_cookie : false,
      routes : [
        "form-a-multi-academy-trust/",
      ],
    },
    "servicesupportusersprerelease" : {
      order : 170,
      require_cookie : true,
      routes : [
        "service-support/users",
      ]
    },
    "confirmdeleteprerelease" : {
      order : 180,
      require_cookie : true,
      routes : [
        "${local.complete_dotnet_project_prefix}/confirm_delete",
      ],
      operator : "RegEx",
    },
  }

  complete_dotnet_ruby_migration_all = {
    development = local.complete_dotnet_ruby_migration_paths_development
    test        = local.complete_dotnet_ruby_migration_paths_test
    production  = local.complete_dotnet_ruby_migration_paths_production
  }

  complete_dotnet_ruby_migration_paths = lookup(local.complete_dotnet_ruby_migration_all, local.azure_environment, {})
}
