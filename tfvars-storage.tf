resource "azurerm_storage_account" "tfvars" {
  #checkov:skip=CKV_AZURE_59: Suppressing check pending review.
  #checkov:skip=CKV_AZURE_33: Suppressing check pending review.
  #checkov:skip=CKV_AZURE_190: Suppressing check pending review.
  #checkov:skip=CKV_AZURE_206: Suppressing check pending review.
  #checkov:skip=CKV2_AZURE_41: Suppressing check pending review.
  #checkov:skip=CKV2_AZURE_38: Suppressing check pending review.
  #checkov:skip=CKV2_AZURE_40: Suppressing check pending review.
  #checkov:skip=CKV2_AZURE_1: Suppressing check pending review.
  #checkov:skip=CKV2_AZURE_47: Suppressing check pending review.
  #checkov:skip=CKV2_AZURE_33: Suppressing check pending review.

  name                          = "${local.environment}rsdfdfvars"
  resource_group_name           = local.resource_group.name
  location                      = local.azure_location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  min_tls_version               = "TLS1_2"
  https_traffic_only_enabled    = true
  public_network_access_enabled = true

  tags = local.tags
}

resource "azurerm_storage_container" "tfvars" {
  # checkov:skip=CKV2_AZURE_21: Suppressing check pending review.

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
  #checkov:skip=CKV_AZURE_35: Suppressing check pending review.

  storage_account_id         = azurerm_storage_account.tfvars.id
  default_action             = "Allow"
  bypass                     = []
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
