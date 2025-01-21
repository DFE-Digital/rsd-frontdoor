module "azurerm_key_vault" {
  source = "github.com/DFE-Digital/terraform-azurerm-key-vault-tfvars?ref=v0.5.1"

  environment                             = local.environment
  project_name                            = "-rsdfd"
  existing_resource_group                 = local.resource_group.name
  azure_location                          = local.azure_location
  key_vault_access_use_rbac_authorization = true
  key_vault_access_users                  = []
  key_vault_access_ipv4                   = local.key_vault_access_ipv4
  tfvars_filename                         = local.tfvars_filename
  diagnostic_log_analytics_workspace_id   = azurerm_log_analytics_workspace.diagnostics[0].id
  tags                                    = local.tags
}
