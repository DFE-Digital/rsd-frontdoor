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
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.8.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_cdn_frontdoor_custom_domain.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_custom_domain) | resource |
| [azurerm_cdn_frontdoor_endpoint.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) | resource |
| [azurerm_cdn_frontdoor_origin.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) | resource |
| [azurerm_cdn_frontdoor_origin_group.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) | resource |
| [azurerm_cdn_frontdoor_profile.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) | resource |
| [azurerm_cdn_frontdoor_route.rsd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) | resource |
| [azurerm_cdn_frontdoor_rule.security](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.vdp_security_txt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule.vdp_thanks_txt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule) | resource |
| [azurerm_cdn_frontdoor_rule_set.security](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_cdn_frontdoor_rule_set.vdp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_rule_set) | resource |
| [azurerm_log_analytics_workspace.diagnostics](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_management_lock.rsd_frontdoor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_diagnostic_setting.cdn](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group.rsd_frontdoor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.existing_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_azure_client_id"></a> [azure\_client\_id](#input\_azure\_client\_id) | Service Principal Client ID | `string` | n/a | yes |
| <a name="input_azure_client_secret"></a> [azure\_client\_secret](#input\_azure\_client\_secret) | Service Principal Client Secret | `string` | n/a | yes |
| <a name="input_azure_location"></a> [azure\_location](#input\_azure\_location) | Azure location in which to launch resources. | `string` | n/a | yes |
| <a name="input_azure_subscription_id"></a> [azure\_subscription\_id](#input\_azure\_subscription\_id) | Service Principal Subscription ID | `string` | n/a | yes |
| <a name="input_azure_tenant_id"></a> [azure\_tenant\_id](#input\_azure\_tenant\_id) | Service Principal Tenant ID | `string` | n/a | yes |
| <a name="input_enable_frontdoor"></a> [enable\_frontdoor](#input\_enable\_frontdoor) | Launch the FrontDoor CDN | `bool` | `false` | no |
| <a name="input_enable_frontdoor_vdp_redirects"></a> [enable\_frontdoor\_vdp\_redirects](#input\_enable\_frontdoor\_vdp\_redirects) | Creates a redirect rule set for security.txt and thanks.txt to an external Vulnerability Disclosure Program service | `bool` | `true` | no |
| <a name="input_enable_resource_group_lock"></a> [enable\_resource\_group\_lock](#input\_enable\_resource\_group\_lock) | Enabling this will add a Resource Lock to the Resource Group preventing any resources from being deleted | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | Use an existing resource group instead of launching a new one | `string` | `""` | no |
| <a name="input_frontdoor_enable_access_logs"></a> [frontdoor\_enable\_access\_logs](#input\_frontdoor\_enable\_access\_logs) | Enable logging of HTTP Requests | `bool` | `false` | no |
| <a name="input_frontdoor_enable_health_probe_logs"></a> [frontdoor\_enable\_health\_probe\_logs](#input\_frontdoor\_enable\_health\_probe\_logs) | Enable logging of Health Probe results | `bool` | `false` | no |
| <a name="input_frontdoor_enable_waf_logs"></a> [frontdoor\_enable\_waf\_logs](#input\_frontdoor\_enable\_waf\_logs) | Enable logging of WAF events | `bool` | `true` | no |
| <a name="input_frontdoor_origins"></a> [frontdoor\_origins](#input\_frontdoor\_origins) | Map of FrontDoor origin objects to add to the FrontDoor CDN | <pre>map(object({<br/>    origin_host               = string<br/>    origin_host_header        = optional(string, null)<br/>    custom_domains            = optional(list(string), [])<br/>    enable_health_probe       = optional(bool, true)<br/>    health_probe_interval     = optional(number, 60)<br/>    health_probe_request_type = optional(string, "HEAD")<br/>    health_probe_path         = optional(string, "/")<br/>    private_link_target_id    = optional(string, null)<br/>    forwarding_protocol       = optional(string, "HttpsOnly")<br/>    enable_security_headers   = optional(bool, true)<br/>  }))</pre> | `{}` | no |
| <a name="input_frontdoor_response_timeout"></a> [frontdoor\_response\_timeout](#input\_frontdoor\_response\_timeout) | Maximum FrontDoor response timeout in seconds | `number` | `120` | no |
| <a name="input_frontdoor_sku"></a> [frontdoor\_sku](#input\_frontdoor\_sku) | FrontDoor SKU | `string` | `"Premium_AzureFrontDoor"` | no |
| <a name="input_frontdoor_vdp_destination_hostname"></a> [frontdoor\_vdp\_destination\_hostname](#input\_frontdoor\_vdp\_destination\_hostname) | Requires 'enable\_frontdoor\_vdp\_redirects' to be set to 'true'. Hostname to redirect security.txt and thanks.txt to | `string` | `"vdp.security.education.gov.uk"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
