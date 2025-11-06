# RSD FrontDoor Terraform project

[![Terraform CI](https://github.com/DFE-Digital/rsd-frontdoor/actions/workflows/continuous-integration-terraform.yml/badge.svg?branch=main)](./actions/workflows/continuous-integration-terraform.yml?branch=main)

This project creates and manages the RSD FrontDoor CDN.

## Usage

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.8 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.28.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_cdn_frontdoor_custom_domain.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_custom_domain) | resource |
| [azurerm_cdn_frontdoor_custom_domain_association.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_custom_domain_association) | resource |
| [azurerm_cdn_frontdoor_endpoint.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) | resource |
| [azurerm_cdn_frontdoor_firewall_policy.waf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_firewall_policy) | resource |
| [azurerm_cdn_frontdoor_origin.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) | resource |
| [azurerm_cdn_frontdoor_origin_group.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) | resource |
| [azurerm_cdn_frontdoor_profile.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) | resource |
| [azurerm_cdn_frontdoor_route.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) | resource |
| [azurerm_cdn_frontdoor_rule.add_response_headers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.complete_dotnet_ruby_migration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.dotnet_disable_override](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.dotnet_disable_override_reverse](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.host_redirects](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.remove_response_headers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.security](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.vdp_security_txt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.vdp_thanks_txt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule_set.complete_dotnet_ruby_migration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_rule_set.host_redirects](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_rule_set.response_headers](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_rule_set.security](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_rule_set.vdp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_security_policy.waf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_security_policy) | resource |
| [azurerm_log_analytics_workspace.diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_management_lock.rsd_frontdoor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_diagnostic_setting.cdn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group.rsd_frontdoor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_dns_zone.zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/dns_zone) | data source |
| [azurerm_resource_group.existing_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | Service Principal Client ID | `string` | n/a | yes |
| <a name="input_azure_client_secret"></a> [azure\_client\_secret](#input\_azure\_client\_secret) | Service Principal Client Secret | `string` | n/a | yes |
| <a name="input_azure_location"></a> [azure\_location](#input\_azure\_location) | Azure location in which to launch resources. | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Service Principal Subscription ID | `string` | n/a | yes |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | Service Principal Tenant ID | `string` | n/a | yes |
| <a name="input_enable_custom_reroute_reversal"></a> [enable\_custom\_reroute\_reversal](#input\_enable\_custom\_reroute\_reversal) | Enable traffic reversal from dotnet to ruby in development environment | `bool` | `false` | no |
| <a name="input_enable_custom_reroute_ruleset"></a> [enable\_custom\_reroute\_ruleset](#input\_enable\_custom\_reroute\_ruleset) | Toggle on/off the re-routing of traffic accessing the Ruby Complete app under certain request paths which should route to the .NET Complete app backend origin | `bool` | `false` | no |
| <a name="input_enable_frontdoor"></a> [enable\_frontdoor](#input\_enable\_frontdoor) | Launch the FrontDoor CDN | `bool` | `false` | no |
| <a name="input_enable_frontdoor_vdp_redirects"></a> [enable\_frontdoor\_vdp\_redirects](#input\_enable\_frontdoor\_vdp\_redirects) | Creates a redirect rule set for security.txt and thanks.txt to an external Vulnerability Disclosure Program service | `bool` | `true` | no |
| <a name="input_enable_frontdoor_waf"></a> [enable\_frontdoor\_waf](#input\_enable\_frontdoor\_waf) | Enable or Disable the Front Door WAF Policy | `bool` | `true` | no |
| <a name="input_enable_resource_group_lock"></a> [enable\_resource\_group\_lock](#input\_enable\_resource\_group\_lock) | Enabling this will add a Resource Lock to the Resource Group preventing any resources from being deleted | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | Use an existing resource group instead of launching a new one | `string` | `""` | no |
| <a name="input_frontdoor_enable_access_logs"></a> [frontdoor\_enable\_access\_logs](#input\_frontdoor\_enable\_access\_logs) | Enable logging of HTTP Requests | `bool` | `false` | no |
| <a name="input_frontdoor_enable_health_probe_logs"></a> [frontdoor\_enable\_health\_probe\_logs](#input\_frontdoor\_enable\_health\_probe\_logs) | Enable logging of Health Probe results | `bool` | `false` | no |
| <a name="input_frontdoor_enable_waf_logs"></a> [frontdoor\_enable\_waf\_logs](#input\_frontdoor\_enable\_waf\_logs) | Enable logging of WAF events | `bool` | `true` | no |
| <a name="input_frontdoor_origins"></a> [frontdoor\_origins](#input\_frontdoor\_origins) | Map of FrontDoor origin objects to add to the FrontDoor CDN | <pre>map(object({<br/>    origin_host         = string<br/>    origin_host_header  = optional(string, null)<br/>    custom_domains      = optional(list(string), [])<br/>    enable_health_probe = optional(bool, true)<br/>    managed_dns_zones = optional(list(object({<br/>      name                = string<br/>      resource_group_name = string<br/>    })), [])<br/>    health_probe_interval     = optional(number, 60)<br/>    health_probe_request_type = optional(string, "HEAD")<br/>    health_probe_path         = optional(string, "/")<br/>    private_link_target_id    = optional(string, null)<br/>    private_link_target_type  = optional(string, "managedEnvironments")<br/>    forwarding_protocol       = optional(string, "HttpsOnly")<br/>    enable_security_headers   = optional(bool, true)<br/>    redirects = optional(list(object({<br/>      from = string<br/>      to   = string<br/>    })), [])<br/>    add_http_response_headers = optional(list(object({<br/>      name  = string<br/>      value = string<br/>    })), [])<br/>    remove_http_response_headers = optional(list(object({<br/>      name = string<br/>    })), [])<br/>    waf_custom_rules = optional(map(object({<br/>      action = string<br/>      match_conditions : map(object({<br/>        match_variable : string,<br/>        match_values : optional(list(string), []),<br/>        operator : optional(string, "Any"),<br/>        selector : optional(string, null),<br/>        negation_condition : optional(bool, false),<br/>      }))<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_frontdoor_response_timeout"></a> [frontdoor\_response\_timeout](#input\_frontdoor\_response\_timeout) | Maximum FrontDoor response timeout in seconds | `number` | `120` | no |
| <a name="input_frontdoor_sku"></a> [frontdoor\_sku](#input\_frontdoor\_sku) | FrontDoor SKU | `string` | `"Premium_AzureFrontDoor"` | no |
| <a name="input_frontdoor_vdp_destination_hostname"></a> [frontdoor\_vdp\_destination\_hostname](#input\_frontdoor\_vdp\_destination\_hostname) | Requires 'enable\_frontdoor\_vdp\_redirects' to be set to 'true'. Hostname to redirect security.txt and thanks.txt to | `string` | `"vdp.security.education.gov.uk"` | no |
| <a name="input_key_vault_access_ipv4"></a> [key\_vault\_access\_ipv4](#input\_key\_vault\_access\_ipv4) | List of IPv4 Addresses that are permitted to access the Key Vault | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources | `map(string)` | `{}` | no |
| <a name="input_tfvars_filename"></a> [tfvars\_filename](#input\_tfvars\_filename) | tfvars filename. This file is uploaded and stored encrypted within Key Vault, to ensure that the latest tfvars are stored in a shared place. | `string` | n/a | yes |
| <a name="input_waf_custom_rules"></a> [waf\_custom\_rules](#input\_waf\_custom\_rules) | Map of all Custom rules you want to apply to the WAF | <pre>map(object({<br/>    priority : number,<br/>    action : string<br/>    match_conditions : map(object({<br/>      match_variable : string,<br/>      match_values : optional(list(string), []),<br/>      operator : optional(string, "Any"),<br/>      selector : optional(string, null),<br/>      negation_condition : optional(bool, false),<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_waf_enable_bot_protection"></a> [waf\_enable\_bot\_protection](#input\_waf\_enable\_bot\_protection) | Enable Bot Protection rules in the WAF Policy | `bool` | `true` | no |
| <a name="input_waf_enable_rate_limiting"></a> [waf\_enable\_rate\_limiting](#input\_waf\_enable\_rate\_limiting) | Enable a Rate Limit rule in the WAF Policy | `bool` | `true` | no |
| <a name="input_waf_managed_rulesets"></a> [waf\_managed\_rulesets](#input\_waf\_managed\_rulesets) | A map of managed rule sets and their group-level overrides. The key is the rule set type and version, e.g., 'Microsoft\_DefaultRuleSet\_2.1'. | <pre>map(object({<br/>    action = optional(string, "Block")<br/>    overrides = optional(map(object({<br/>      disabled_rules = optional(list(string), [])<br/>      exclusions = optional(list(object({<br/>        match_variable = string<br/>        operator       = string<br/>        selector       = string<br/>      })), [])<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_waf_mode"></a> [waf\_mode](#input\_waf\_mode) | Set whether the WAF is in Detection or Prevention mode | `string` | `"Detection"` | no |
| <a name="input_waf_rate_limiting_bypass_ip_list"></a> [waf\_rate\_limiting\_bypass\_ip\_list](#input\_waf\_rate\_limiting\_bypass\_ip\_list) | List of IPv4 Addresses that should bypass the Rate Limit rules | `list(string)` | `[]` | no |
| <a name="input_waf_rate_limiting_duration_in_minutes"></a> [waf\_rate\_limiting\_duration\_in\_minutes](#input\_waf\_rate\_limiting\_duration\_in\_minutes) | Number of minutes to block an IP address when it exceeds rate limit | `number` | `5` | no |
| <a name="input_waf_rate_limiting_threshold"></a> [waf\_rate\_limiting\_threshold](#input\_waf\_rate\_limiting\_threshold) | Number of evaluated requests that are permitted within 'waf\_rate\_limiting\_duration\_in\_minutes' before being rate limited | `number` | `200` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
