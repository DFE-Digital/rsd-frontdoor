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
    origin_host               = string
    origin_host_header        = optional(string, null)
    custom_domains            = optional(list(string), [])
    enable_health_probe       = optional(bool, true)
    health_probe_interval     = optional(number, 60)
    health_probe_request_type = optional(string, "HEAD")
    health_probe_path         = optional(string, "/")
    private_link_target_id    = optional(string, null)
    forwarding_protocol       = optional(string, "HttpsOnly")
    enable_security_headers   = optional(bool, true)
    add_http_response_headers = optional(list(object({
      name  = string
      value = string
    })), [])
    remove_http_response_headers = optional(list(object({
      name = string
    })), [])
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
