terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "adf_rg" {
  name     = "adf-rg"
  location = "East US"

  tags = {
    Environment = "Demo"
    Project     = "Azure-Data-Factory"
  }
}

# Storage Account
resource "azurerm_storage_account" "adf_storage" {
  name                     = "adfstoragedemo123"
  resource_group_name      = azurerm_resource_group.adf_rg.name
  location                 = azurerm_resource_group.adf_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "Demo"
    Project     = "Azure-Data-Factory"
  }
}

# Storage Containers
resource "azurerm_storage_container" "source" {
  name                  = "source"
  storage_account_name  = azurerm_storage_account.adf_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "destination" {
  name                  = "destination"
  storage_account_name  = azurerm_storage_account.adf_storage.name
  container_access_type = "private"
}

# Upload sample file to source container
resource "azurerm_storage_blob" "input_file" {
  name                   = "input.txt"
  storage_account_name   = azurerm_storage_account.adf_storage.name
  storage_container_name = azurerm_storage_container.source.name
  type                   = "Block"
  source_content         = "Hello World\nSample data for Azure Data Factory demo"
}

# Data Factory
resource "azurerm_data_factory" "adf" {
  name                = "adf-simple-demo"
  location            = azurerm_resource_group.adf_rg.location
  resource_group_name = azurerm_resource_group.adf_rg.name

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Demo"
    Project     = "Azure-Data-Factory"
  }
}

# Data Factory Linked Service for Azure Blob Storage
resource "azurerm_data_factory_linked_service_azure_blob_storage" "blob_storage" {
  name              = "AzureBlobStorage1"
  data_factory_id   = azurerm_data_factory.adf.id
  connection_string = azurerm_storage_account.adf_storage.primary_connection_string
}

# Source Dataset
resource "azurerm_data_factory_dataset_delimited_text" "source_dataset" {
  name            = "SourceDataset"
  data_factory_id = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.blob_storage.name

  azure_blob_storage_location {
    container = azurerm_storage_container.source.name
    filename  = "input.txt"
  }

  column_delimiter    = ""
  row_delimiter       = "\\n"
  first_row_as_header = false
}

# Sink Dataset
resource "azurerm_data_factory_dataset_delimited_text" "sink_dataset" {
  name            = "SinkDataset"
  data_factory_id = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_service_azure_blob_storage.blob_storage.name

  azure_blob_storage_location {
    container = azurerm_storage_container.destination.name
    filename  = "output.txt"
  }
  
  column_delimiter    = ""
  row_delimiter       = "\\n"
  first_row_as_header = false
}

# Data Factory Pipeline
resource "azurerm_data_factory_pipeline" "copy_pipeline" {
  name            = "CopyBlobPipeline"
  data_factory_id = azurerm_data_factory.adf.id

  activities_json = jsonencode([
    {
      name = "CopyFromSourceToDestination"
      type = "Copy"
      inputs = [
        {
          referenceName = azurerm_data_factory_dataset_delimited_text.source_dataset.name
          type          = "DatasetReference"
        }
      ]
      outputs = [
        {
          referenceName = azurerm_data_factory_dataset_delimited_text.sink_dataset.name
          type          = "DatasetReference"
        }
      ]
      typeProperties = {
        source = {
          type = "DelimitedTextSource"
        }
        sink = {
          type = "DelimitedTextSink"
        }
      }
    }
  ])
}

# Data Factory Trigger
resource "azurerm_data_factory_trigger_schedule" "daily_trigger" {
  name            = "DailyTrigger"
  data_factory_id = azurerm_data_factory.adf.id
  pipeline_name   = azurerm_data_factory_pipeline.copy_pipeline.name

  frequency = "Day"
  interval  = 1
  activated = false # Set to true to activate the trigger

  schedule {
    hours   = [9]
    minutes = [0]
  }
}