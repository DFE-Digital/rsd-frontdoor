resource "azurerm_storage_account" "tfvars" {
  #checkov:skip=CKV_AZURE_33: Ensure Storage logging is enabled for Queue service for read, write and delete requests
  #checkov:skip=CKV_AZURE_206: Ensure that Storage Accounts use replication
  #checkov:skip=CKV2_AZURE_1: Ensure storage for critical data are encrypted with Customer Managed Key
  #checkov:skip=CKV2_AZURE_33: Ensure storage account is configured with private endpoint

  name                            = "${local.environment}rsdfdfvars"
  resource_group_name             = local.resource_group.name
  location                        = local.azure_location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  https_traffic_only_enabled      = true
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = local.tags
}

resource "azurerm_storage_container" "tfvars" {
  # checkov:skip=CKV2_AZURE_21: Ensure Storage logging is enabled for Blob service for read requests

  name                  = "${local.environment}rsdfdfvars"
  storage_account_name  = azurerm_storage_account.tfvars.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "tfvars" {
  name                   = local.tfvars_filename
  storage_account_name   = azurerm_storage_account.tfvars.name
  storage_container_name = azurerm_storage_container.tfvars.name
  type                   = "Block"
  source                 = local.tfvars_filename
  content_md5            = filemd5(local.tfvars_filename)
  access_tier            = "Cool"
}

resource "azurerm_storage_account_network_rules" "tfvars" {
  storage_account_id         = azurerm_storage_account.tfvars.id
  default_action             = "Deny"
  bypass                     = ["AzureServices"]
  virtual_network_subnet_ids = []
}

resource "null_resource" "tfvars" {
  provisioner "local-exec" {
    interpreter = [local.bash, "-c"]
    command     = "./scripts/check-tfvars-against-remote.sh -c \"${azurerm_storage_container.tfvars.name}\" -a \"${azurerm_storage_account.tfvars.name}\" -f \"${local.tfvars_filename}\""
  }

  triggers = {
    tfvar_file_md5 = filemd5(local.tfvars_filename)
  }
}
