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

## 🔹 Step 7: Create Linked Service (Blob Storage)

### Linked Service JSON

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

---

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

---

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

## � Infrastructure as Code (Terraform)

This project now includes **Terraform Infrastructure as Code** for automated deployment!

### 🚀 Quick Deploy with Terraform

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

### 🎯 What Terraform Creates

- ✅ Resource Group (`adf-rg`)
- ✅ Storage Account (`adfstoragedemo123`)
- ✅ Blob Containers (`source`, `destination`)
- ✅ Azure Data Factory (`adf-simple-demo`)
- ✅ Linked Service (Blob Storage connection)
- ✅ Datasets (Source and Sink for delimited text)
- ✅ Pipeline (Copy activity from source to destination)
- ✅ Scheduled Trigger (Daily at 9 AM, disabled by default)
- ✅ Sample Data (`input.txt` automatically uploaded)

### 📁 Terraform Structure

```
terraform/
├── main.tf              # Main infrastructure configuration
├── variables.tf         # Input variables
├── outputs.tf          # Output values
├── terraform.tfvars.example  # Example variables
├── deploy.sh           # Automated deployment script
├── README.md           # Terraform documentation
└── .gitignore         # Terraform-specific gitignore
```

### 🧪 Test the Pipeline

```bash
# Trigger pipeline run
az datafactory pipeline create-run \
  --factory-name adf-simple-demo \
  --resource-group adf-rg \
  --name CopyBlobPipeline

# Check results
az storage blob list \
  --account-name adfstoragedemo123 \
  --container-name destination \
  --output table
```

---

## �📌 Interview / Training One-Line Explanation

> *Azure Data Factory is a cloud-based ETL service used to move and transform data between different data sources using pipelines.*

