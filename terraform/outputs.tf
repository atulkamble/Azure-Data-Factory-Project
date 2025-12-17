output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.adf_rg.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.adf_storage.name
}

output "storage_account_primary_connection_string" {
  description = "Primary connection string for the storage account"
  value       = azurerm_storage_account.adf_storage.primary_connection_string
  sensitive   = true
}

output "data_factory_name" {
  description = "Name of the Azure Data Factory"
  value       = azurerm_data_factory.adf.name
}

output "data_factory_id" {
  description = "ID of the Azure Data Factory"
  value       = azurerm_data_factory.adf.id
}

output "source_container_url" {
  description = "URL of the source container"
  value       = "https://${azurerm_storage_account.adf_storage.name}.blob.core.windows.net/${azurerm_storage_container.source.name}"
}

output "destination_container_url" {
  description = "URL of the destination container"
  value       = "https://${azurerm_storage_account.adf_storage.name}.blob.core.windows.net/${azurerm_storage_container.destination.name}"
}

output "pipeline_name" {
  description = "Name of the copy pipeline"
  value       = azurerm_data_factory_pipeline.copy_pipeline.name
}