resource "azurerm_storage_account" "ops_manager_storage_account" {
  name                     = random_string.ops_manager_storage_account_name.result
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = var.env_name
    account_for = "ops-manager"
  }
}

resource "azurerm_storage_container" "ops_manager_storage_container" {
  name                  = "opsmanagerimage"
  depends_on            = [azurerm_storage_account.ops_manager_storage_account]
  storage_account_name  = azurerm_storage_account.ops_manager_storage_account.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "ops_manager_image" {
  name                   = "opsman.vhd"
  storage_account_name   = azurerm_storage_account.ops_manager_storage_account.name
  storage_container_name = azurerm_storage_container.ops_manager_storage_container.name
  source_uri             = var.ops_manager_image_uri
  count                  = local.ops_man_vm
  type                   = "Page"
}

resource "azurerm_image" "ops_manager_image" {
  name                = "ops_manager_image"
  location            = var.location
  resource_group_name = var.resource_group_name
  count               = local.ops_man_vm

  os_disk {
    os_type  = "Linux"
    os_state = "Generalized"
    blob_uri = azurerm_storage_blob.ops_manager_image[count.index].url
    size_gb  = 150
  }
}
