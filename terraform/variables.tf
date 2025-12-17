variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "adf-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  default     = "adfstoragedemo123"
}

variable "data_factory_name" {
  description = "Name of the Azure Data Factory"
  type        = string
  default     = "adf-simple-demo"
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "Demo"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "Azure-Data-Factory"
}