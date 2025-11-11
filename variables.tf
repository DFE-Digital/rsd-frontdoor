variable "azure_client_id" {
  description = "Service Principal Client ID"
  type        = string
}

variable "azure_client_secret" {
  description = "Service Principal Client Secret"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Service Principal Tenant ID"
  type        = string
}

variable "azure_subscription_id" {
  description = "Service Principal Subscription ID"
  type        = string
}

variable "azure_location" {
  description = "Azure location in which to launch resources."
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

variable "existing_resource_group" {
  description = "Use an existing resource group instead of launching a new one"
  type        = string
  default     = ""
}

variable "enable_resource_group_lock" {
  description = "Enabling this will add a Resource Lock to the Resource Group preventing any resources from being deleted"
  type        = bool
  default     = false
}

variable "enable_frontdoor" {
  description = "Launch the FrontDoor CDN"
  type        = bool
  default     = false
}

variable "frontdoor_sku" {
  description = "FrontDoor SKU"
  type        = string
  default     = "Premium_AzureFrontDoor"
}

variable "frontdoor_origins" {
  description = "Map of FrontDoor origin objects to add to the FrontDoor CDN"
  type = map(object({
    origin_host         = string
    origin_host_header  = optional(string, null)
    custom_domains      = optional(list(string), [])
    enable_health_probe = optional(bool, true)
    managed_dns_zones = optional(list(object({
      name                = string
      resource_group_name = string
    })), [])
    health_probe_interval     = optional(number, 60)
    health_probe_request_type = optional(string, "HEAD")
    health_probe_path         = optional(string, "/")
    private_link_target_id    = optional(string, null)
    private_link_target_type  = optional(string, "managedEnvironments")
    forwarding_protocol       = optional(string, "HttpsOnly")
    enable_security_headers   = optional(bool, true)
    redirects = optional(list(object({
      from = string
      to   = string
    })), [])
    add_http_response_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    remove_http_response_headers = optional(list(object({
      name = string
    })), [])
    waf_custom_rules = optional(map(object({
      action = string
      match_conditions : map(object({
        match_variable : string,
        match_values : optional(list(string), []),
        operator : optional(string, "Any"),
        selector : optional(string, null),
        negation_condition : optional(bool, false),
      }))
    })), {})
  }))
  default = {}
}

variable "frontdoor_response_timeout" {
  description = "Maximum FrontDoor response timeout in seconds"
  type        = number
  default     = 120
}

variable "enable_frontdoor_vdp_redirects" {
  description = "Creates a redirect rule set for security.txt and thanks.txt to an external Vulnerability Disclosure Program service"
  type        = bool
  default     = true
}

variable "frontdoor_vdp_destination_hostname" {
  description = "Requires 'enable_frontdoor_vdp_redirects' to be set to 'true'. Hostname to redirect security.txt and thanks.txt to"
  type        = string
  default     = "vdp.security.education.gov.uk"
}

variable "frontdoor_enable_waf_logs" {
  description = "Enable logging of WAF events"
  type        = bool
  default     = true
}

variable "frontdoor_enable_access_logs" {
  description = "Enable logging of HTTP Requests"
  type        = bool
  default     = false
}

variable "frontdoor_enable_health_probe_logs" {
  description = "Enable logging of Health Probe results"
  type        = bool
  default     = false
}

variable "key_vault_access_ipv4" {
  description = "List of IPv4 Addresses that are permitted to access the Key Vault"
  type        = list(string)
}

variable "tfvars_filename" {
  description = "tfvars filename. This file is uploaded and stored encrypted within Key Vault, to ensure that the latest tfvars are stored in a shared place."
  type        = string
}

variable "enable_frontdoor_waf" {
  description = "Enable or Disable the Front Door WAF Policy"
  type        = bool
  default     = true
}

variable "waf_mode" {
  description = "Set whether the WAF is in Detection or Prevention mode"
  type        = string
  default     = "Detection"
}

variable "waf_enable_bot_protection" {
  description = "Enable Bot Protection rules in the WAF Policy"
  type        = bool
  default     = true
}

variable "waf_enable_rate_limiting" {
  description = "Enable a Rate Limit rule in the WAF Policy"
  type        = bool
  default     = true
}

variable "waf_rate_limiting_duration_in_minutes" {
  description = "Number of minutes to block an IP address when it exceeds rate limit"
  type        = number
  default     = 5
}

variable "waf_rate_limiting_threshold" {
  description = "Number of evaluated requests that are permitted within 'waf_rate_limiting_duration_in_minutes' before being rate limited"
  type        = number
  default     = 200
}

variable "waf_rate_limiting_bypass_ip_list" {
  description = "List of IPv4 Addresses that should bypass the Rate Limit rules"
  type        = list(string)
  default     = []
}

variable "enable_custom_reroute_ruleset" {
  description = "Toggle on/off the re-routing of traffic accessing the Ruby Complete app under certain request paths which should route to the .NET Complete app backend origin"
  type        = bool
  default     = false
}

variable "enable_custom_reroute_reversal" {
  description = "Enable traffic reversal from dotnet to ruby"
  type        = bool
  default     = false
}
