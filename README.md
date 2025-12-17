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

## 🔹 Step 4: Upload Sample File

```bash
az storage blob upload \
  --account-name adfstoragedemo123 \
  --container-name source \
  --name input.txt \
  --file input.txt
```

---

## 🔹 Step 5: Create Azure Data Factory

```bash
az datafactory factory create \
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
  "name": "SourceDataset",
  "properties": {
    "linkedServiceName": {
      "referenceName": "AzureBlobStorageLS",
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

### Sink Dataset (Blob – output.txt)

```json
{
  "name": "SinkDataset",
  "properties": {
    "linkedServiceName": {
      "referenceName": "AzureBlobStorageLS",
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

## 📌 Interview / Training One-Line Explanation

> *Azure Data Factory is a cloud-based ETL service used to move and transform data between different data sources using pipelines.*

