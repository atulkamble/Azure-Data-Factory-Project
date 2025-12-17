# 🚀 Azure Data Factory Project

## 🎯 Project Overview

**Copy a text file from Azure Blob Storage (Source) to another Blob container (Sink)** using **Azure Data Factory**.

This project demonstrates two approaches:
1. **🖱️ Manual Setup** - Step-by-step Azure Portal configuration
2. **🤖 Infrastructure as Code** - Automated Terraform deployment

---

## 🏗️ Architecture

```
[Source Container]  ──►  [Azure Data Factory]  ──►  [Destination Container]
     input.txt                 Copy Activity               output.txt
```

---

## ✅ Prerequisites

### For Manual Setup:
* ✅ Azure Subscription
* ✅ Azure CLI installed and configured (`az login`)
* ✅ Basic knowledge of Azure Portal

### For Terraform Setup:
* ✅ Azure Subscription
* ✅ Azure CLI installed and configured (`az login`)
* ✅ Terraform installed (v1.0+)

---

# 🖱️ Method 1: Manual Setup (Step-by-Step)

## 🔹 Step 1: Create Resource Group

```bash
az group create \
  --name adf-rg \
  --location eastus
```

## 🔹 Step 2: Create Storage Account

```bash
az storage account create \
  --name adfstoragedemo123 \
  --resource-group adf-rg \
  --location eastus \
  --sku Standard_LRS
```

## 🔹 Step 3: Create Storage Containers

```bash
# Create source container
az storage container create \
  --account-name adfstoragedemo123 \
  --name source

# Create destination container
az storage container create \
  --account-name adfstoragedemo123 \
  --name destination
```

## 🔹 Step 4: Create and Upload Sample File

```bash
# Create sample file
echo "Hello World
Sample data for Azure Data Factory demo" > input.txt

# Upload to source container
az storage blob upload \
  --account-name adfstoragedemo123 \
  --container-name source \
  --name input.txt \
  --file input.txt
```

## 🔹 Step 5: Install Data Factory Extension & Create ADF

```bash
# Install Azure Data Factory CLI extension
az extension add --name datafactory

# Create Azure Data Factory
az datafactory create \
  --resource-group adf-rg \
  --factory-name adf-simple-demo \
  --location eastus
```

## 🔹 Step 6: Configure Data Factory (Azure Portal)

1. **Open Azure Portal** → **Data Factories** → `adf-simple-demo`
2. **Click "Open Azure Data Factory Studio"**

## 🔹 Step 7: Create Linked Service

**Navigation:** Author → Manage → Linked Services → New

**Configuration:**
- **Type:** Azure Blob Storage
- **Name:** AzureBlobStorage1
- **Connection Method:** Connection String

**JSON Configuration:**

```json
{
  "properties": {
    "type": "AzureBlobStorage",
    "typeProperties": {
      "connectionString": "DefaultEndpointsProtocol=https;AccountName=adfstoragedemo123;AccountKey=<KEY>;EndpointSuffix=core.windows.net"
    }
  }
}
```

## 🔹 Step 8: Create Datasets

### Source Dataset
**Navigation:** Author → Datasets → New Dataset → Azure Blob Storage → DelimitedText

**Configuration:**
- **Name:** SourceDataset
- **Linked Service:** AzureBlobStorage1
- **File Path:** Container: `source`, File: `input.txt`

**JSON:**
```json
{
  "properties": {
    "linkedServiceName": {
      "referenceName": "AzureBlobStorage1",
      "type": "LinkedServiceReference"
    },
    "type": "DelimitedText",
    "typeProperties": {
      "location": {
        "type": "AzureBlobStorageLocation",
        "container": "source",
        "fileName": "input.txt"
      }
    }
  }
}
```

### Sink Dataset
**Configuration:**
- **Name:** SinkDataset
- **Linked Service:** AzureBlobStorage1
- **File Path:** Container: `destination`, File: `output.txt`

**JSON:**
```json
{
  "properties": {
    "linkedServiceName": {
      "referenceName": "AzureBlobStorage1",
      "type": "LinkedServiceReference"
    },
    "type": "DelimitedText",
    "typeProperties": {
      "location": {
        "type": "AzureBlobStorageLocation",
        "container": "destination",
        "fileName": "output.txt"
      }
    }
  }
}
```

## 🔹 Step 9: Create Pipeline

**Navigation:** Author → Pipelines → New Pipeline

**Configuration:**
- **Name:** CopyBlobPipeline
- **Activity:** Copy Data
- **Source:** SourceDataset
- **Sink:** SinkDataset

**JSON:**
```json
{
  "name": "CopyBlobPipeline",
  "properties": {
    "activities": [
      {
        "name": "CopyFromSourceToDestination",
        "type": "Copy",
        "inputs": [
          {
            "referenceName": "SourceDataset",
            "type": "DatasetReference"
          }
        ],
        "outputs": [
          {
            "referenceName": "SinkDataset",
            "type": "DatasetReference"
          }
        ],
        "typeProperties": {
          "source": {
            "type": "DelimitedTextSource"
          },
          "sink": {
            "type": "DelimitedTextSink"
          }
        }
      }
    ]
  }
}
```

## 🔹 Step 10: Validate & Publish

1. ✅ Click **Validate All** to check for errors
2. ✅ Click **Publish** to deploy changes

## 🔹 Step 11: Test Pipeline

1. 👉 Click **Add Trigger → Trigger Now**
2. 📊 Monitor the run in **Monitor → Pipeline Runs**

## 🎉 Verify Results

```bash
# Check if output file was created
az storage blob list \
  --account-name adfstoragedemo123 \
  --container-name destination \
  --output table

# Download and view the output file
az storage blob download \
  --account-name adfstoragedemo123 \
  --container-name destination \
  --name output.txt \
  --file output.txt && cat output.txt
```

---

# 🤖 Method 2: Infrastructure as Code (Terraform)

## 🚀 Quick Start

```bash
# Clone or navigate to project
cd terraform/

# Initialize Terraform
terraform init

# Review deployment plan
terraform plan

# Deploy infrastructure
terraform apply -auto-approve
```

## 🎯 What Gets Created Automatically

| Resource | Name | Description |
|----------|------|-------------|
| 📁 Resource Group | `adf-rg` | Container for all resources |
| 💾 Storage Account | `adfstoragedemo123` | Blob storage for data |
| 📦 Source Container | `source` | Container with input.txt |
| 📦 Destination Container | `destination` | Target for copied data |
| 🏭 Data Factory | `adf-simple-demo` | ETL orchestration service |
| 🔗 Linked Service | `AzureBlobStorage1` | Connection to storage |
| 📋 Source Dataset | `SourceDataset` | Points to input.txt |
| 📋 Sink Dataset | `SinkDataset` | Points to output.txt |
| 🔄 Pipeline | `CopyBlobPipeline` | Copy activity workflow |
| ⏰ Trigger | `DailyTrigger` | Scheduled execution (disabled) |
| 📄 Sample Data | `input.txt` | Auto-uploaded test file |

## ⚙️ Terraform Configuration

### 📁 File Structure
```
terraform/
├── main.tf                    # Infrastructure resources
├── variables.tf              # Input parameters  
├── outputs.tf               # Resource information
├── terraform.tfvars.example # Configuration template
├── deploy.sh               # Automated deployment
├── README.md              # Terraform docs
└── .gitignore            # Git exclusions
```

### 🎛️ Customization

1. **Copy example config:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit values:**
   ```hcl
   resource_group_name   = "my-adf-rg"
   location              = "West US 2"
   storage_account_name  = "mystorageaccount123"
   data_factory_name     = "my-data-factory"
   environment          = "Production"
   ```

## 🧪 Testing the Deployment

```bash
# Trigger pipeline manually
az datafactory pipeline create-run \
  --factory-name adf-simple-demo \
  --resource-group adf-rg \
  --name CopyBlobPipeline

# Monitor run status
az datafactory pipeline-run show \
  --factory-name adf-simple-demo \
  --resource-group adf-rg \
  --run-id <RUN_ID>

# Verify results
az storage blob list \
  --account-name adfstoragedemo123 \
  --container-name destination \
  --output table
```

## 🧹 Cleanup

```bash
# Destroy all resources
terraform destroy -auto-approve
```

---

# 📊 Comparison: Manual vs Terraform

| Aspect | Manual Setup | Terraform |
|--------|--------------|-----------|
| ⏱️ **Setup Time** | 30-60 minutes | 5 minutes |
| 🔄 **Repeatability** | Manual errors possible | 100% consistent |
| 📝 **Documentation** | Screenshots/notes | Self-documenting code |
| 🔧 **Customization** | Portal configuration | Variables & parameters |
| 🏢 **Enterprise Ready** | Manual governance | Version controlled |
| 🧹 **Cleanup** | Manual deletion | One command |
| 📈 **Scaling** | Repeat manually | Copy/modify code |
| 🛡️ **Best Practices** | Depends on user | Built-in standards |

---

## 🧠 Key Concepts Covered

- **Azure Data Factory**: Cloud ETL/ELT service
- **Linked Service**: Connection to external data stores
- **Dataset**: Pointer to specific data in a linked service
- **Pipeline**: Container for activities that perform tasks
- **Copy Activity**: Transfers data between source and sink
- **Trigger**: Mechanism to execute pipelines
- **Infrastructure as Code**: Automated, version-controlled deployments

---

## 🎯 Learning Outcomes

After completing this project, you will understand:

1. **Manual Azure Data Factory Configuration**
   - Creating and configuring ADF components via Azure Portal
   - Understanding the relationship between datasets, pipelines, and activities
   - Monitoring and troubleshooting pipeline runs

2. **Infrastructure as Code with Terraform**
   - Automating Azure resource deployment
   - Managing infrastructure through version control
   - Implementing repeatable, scalable cloud architectures

3. **Best Practices**
   - Security considerations for data movement
   - Resource naming conventions and organization
   - Monitoring and operational excellence

---

## 📚 Additional Resources

- 📖 [Azure Data Factory Documentation](https://docs.microsoft.com/en-us/azure/data-factory/)
- 🏗️ [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- 🎓 [Azure Data Factory Learning Path](https://docs.microsoft.com/en-us/learn/paths/data-integration-scale-azure-data-factory/)

---

## 📌 One-Line Summary

> *Azure Data Factory is a cloud-based ETL service that enables automated data movement and transformation between various data sources using configurable pipelines, deployable through both manual configuration and Infrastructure as Code approaches.*