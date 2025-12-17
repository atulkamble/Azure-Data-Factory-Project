# 🚀 Azure Data Factory - Terraform Infrastructure

This Terraform configuration creates the complete Azure Data Factory infrastructure as described in the main project.

## 📁 Resources Created

- **Resource Group**: `adf-rg`
- **Storage Account**: `adfstoragedemo123`
- **Storage Containers**: `source` and `destination`
- **Azure Data Factory**: `adf-simple-demo`
- **Linked Service**: Azure Blob Storage connection
- **Datasets**: Source and Sink datasets for delimited text
- **Pipeline**: Copy activity from source to destination
- **Trigger**: Scheduled trigger (disabled by default)
- **Sample File**: `input.txt` uploaded to source container

## 🔧 Prerequisites

1. **Azure CLI** installed and authenticated:
   ```bash
   az login
   ```

2. **Terraform** installed (version 1.0+)
   ```bash
   # macOS
   brew install terraform
   
   # Verify installation
   terraform version
   ```

3. **Azure subscription** with sufficient permissions

## 🚀 Quick Start

### 1. Initialize Terraform
```bash
cd terraform/
terraform init
```

### 2. Plan the Deployment
```bash
terraform plan
```

### 3. Apply the Configuration
```bash
terraform apply
```

### 4. View Outputs
```bash
terraform output
```

## ⚙️ Customization

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` with your values:**
   ```hcl
   resource_group_name   = "my-adf-rg"
   location              = "West US 2"
   storage_account_name  = "mystorageaccount123"  # Must be globally unique
   data_factory_name     = "my-data-factory"
   environment          = "Production"
   project_name         = "My-Project"
   ```

## 🎯 Key Features

- **Infrastructure as Code**: Complete ADF setup in version-controlled Terraform
- **Automated Sample Data**: Automatically uploads `input.txt` to source container
- **Ready-to-Use Pipeline**: Copy activity configured and ready to run
- **Secure Configuration**: Uses managed identity for Data Factory
- **Modular Design**: Easily customizable through variables

## 📋 Post-Deployment Steps

1. **Access Azure Data Factory Studio**:
   - Go to Azure Portal → Data Factories → `adf-simple-demo`
   - Click "Open Azure Data Factory Studio"

2. **Test the Pipeline**:
   - Navigate to Author → Pipelines → `CopyBlobPipeline`
   - Click "Debug" to test the pipeline
   - Check the destination container for `output.txt`

3. **Enable the Trigger** (Optional):
   ```bash
   # Modify main.tf and set activated = true for the trigger
   terraform apply
   ```

## 🧹 Cleanup

```bash
terraform destroy
```

## 📊 Outputs

After deployment, you'll get:
- Resource Group name
- Storage Account name and connection string
- Data Factory name and ID
- Container URLs
- Pipeline name

## 🔍 Troubleshooting

- **Storage account name conflict**: Change `storage_account_name` to a globally unique value
- **Permission issues**: Ensure your Azure account has Contributor role on the subscription
- **Region availability**: Some regions may not support all Azure Data Factory features

---

> 💡 **Tip**: This Terraform configuration mirrors the manual setup described in the main README, but provides infrastructure as code benefits like version control, repeatability, and automation.