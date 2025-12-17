#!/bin/bash

# 🚀 Azure Data Factory Terraform Deployment Script
# This script automates the deployment of Azure Data Factory infrastructure

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Azure CLI is installed and authenticated
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    # Check Azure login
    if ! az account show &> /dev/null; then
        print_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    print_success "Prerequisites check passed!"
}

# Initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized!"
}

# Plan Terraform deployment
plan_terraform() {
    print_status "Planning Terraform deployment..."
    terraform plan -out=tfplan
    print_success "Terraform plan created!"
}

# Apply Terraform deployment
apply_terraform() {
    print_status "Applying Terraform deployment..."
    terraform apply tfplan
    print_success "Terraform deployment completed!"
}

# Show outputs
show_outputs() {
    print_status "Deployment outputs:"
    terraform output
}

# Test the pipeline
test_pipeline() {
    print_status "Getting Data Factory and Pipeline information..."
    
    # Get the resource group and data factory names from terraform output
    RG_NAME=$(terraform output -raw resource_group_name)
    ADF_NAME=$(terraform output -raw data_factory_name)
    PIPELINE_NAME=$(terraform output -raw pipeline_name)
    
    print_status "Triggering pipeline run..."
    
    # Trigger the pipeline
    RUN_ID=$(az datafactory pipeline create-run \
        --factory-name "$ADF_NAME" \
        --resource-group "$RG_NAME" \
        --name "$PIPELINE_NAME" \
        --query "runId" -o tsv)
    
    print_success "Pipeline triggered! Run ID: $RUN_ID"
    print_status "You can monitor the pipeline run in Azure Data Factory Studio"
}

# Main execution
main() {
    echo -e "${BLUE}"
    echo "==========================================="
    echo "🚀 Azure Data Factory Terraform Deployment"
    echo "==========================================="
    echo -e "${NC}"
    
    check_prerequisites
    init_terraform
    plan_terraform
    
    # Ask for confirmation before applying
    echo
    read -p "Do you want to proceed with the deployment? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        apply_terraform
        show_outputs
        
        echo
        read -p "Do you want to test the pipeline? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            test_pipeline
        fi
        
        echo
        print_success "🎉 Deployment completed successfully!"
        print_status "Next steps:"
        echo "  1. Open Azure Portal → Data Factories → $(terraform output -raw data_factory_name)"
        echo "  2. Click 'Open Azure Data Factory Studio'"
        echo "  3. Navigate to Monitor to see pipeline runs"
        echo "  4. Check the destination container for output.txt"
    else
        print_warning "Deployment cancelled."
        exit 1
    fi
}

# Run the main function
main "$@"