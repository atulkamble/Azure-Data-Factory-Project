# 🚀 Azure Data Factory 

## 🧩 Task Objective

**Copy a text file from Azure Blob Storage (Source) to another Blob container (Sink)** using **Azure Data Factory**.

---

## 🏗️ Architecture (Simple)

```
Blob Storage (Source)  --->  Azure Data Factory  --->  Blob Storage (Destination)
```

---

## ✅ Prerequisites

* Azure Subscription
* Azure Storage Account
* Sample file (example: `input.txt`)
* Azure CLI installed (optional but recommended)

---

## 🔹 Step 1: Create Resource Group

```bash
az group create \
  --name adf-rg \
  --location eastus
```

---

## 🔹 Step 2: Create Storage Account

```bash
az storage account create \
  --name adfstoragedemo123 \
  --resource-group adf-rg \
  --location eastus \
  --sku Standard_LRS
```

---

## 🔹 Step 3: Create Containers

```bash
az storage container create \
  --account-name adfstoragedemo123 \
  --name source

az storage container create \
  --account-name adfstoragedemo123 \
  --name destination
```

---

## create file 
```
echo "Hello World" >> input.txt
cat ./input.txt
```
## 🔹 Step 4: Upload Sample File

```bash
az storage blob upload \
  --account-name adfstoragedemo123 \
  --container-name source \
  --name input.txt \
  --file input.txt
```

---
## install extension 
```
az extension add --name datafactory
```
## 🔹 Step 5: Create Azure Data Factory

```bash
az datafactory create \
  --resource-group adf-rg \
  --factory-name adf-simple-demo \
  --location eastus
```

---

## 🔹 Step 6: Open Azure Data Factory Studio

👉 Azure Portal → **Data Factories** → `adf-simple-demo`
👉 Click **Open Azure Data Factory Studio**

---

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

### Source Dataset (Blob – input.txt)

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
      },
      "columnDelimiter": ",",
      "firstRowAsHeader": true
    }
  }
}
```

### Sink Dataset (Blob – output.txt)

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

## 🔹 Step 9: Create Pipeline with Copy Activity

### Pipeline JSON

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

---

## 🔹 Step 10: Validate & Publish

✔ Click **Validate All**
✔ Click **Publish**

---

## 🔹 Step 11: Trigger Pipeline

👉 Click **Add Trigger → Trigger Now**

---

## 🎉 Output

* `input.txt` copied from **source** container
* `output.txt` appears in **destination** container

---

## 🧠 Key Concepts Covered

* Azure Data Factory
* Linked Service
* Dataset
* Pipeline
* Copy Activity
* Trigger

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

