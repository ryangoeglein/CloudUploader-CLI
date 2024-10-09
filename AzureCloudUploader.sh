#!/bin/bash

# Function to display help
display_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help            Show this help message."
    echo "  -a, --account         Use an existing Azure Storage account."
    echo "  -c, --create          Create a new Azure Storage account."
    echo
    echo "This script allows you to upload files to Azure Blob Storage."
    echo "You will be prompted for authentication and account details."
    echo
    exit 0
}

# Function to check if Azure CLI is installed
check_azure_cli_installed() {
    if ! command -v az &> /dev/null; then
        echo "Azure CLI is not installed. Please install it from: https://aka.ms/InstallAzureCli"
        exit 1
    fi
}

# Function to create a Service Principal if it doesn't exist
create_service_principal() {
    read -p "Enter Service Principal Name: " SP_NAME
    echo "Checking if Service Principal $SP_NAME exists..."
    SP_EXISTS=$(az ad sp list --display-name "$SP_NAME" --query '[].appId' --output tsv)
    
    if [[ -z "$SP_EXISTS" ]]; then
        echo "Creating new Service Principal: $SP_NAME..."
        SP_CREDENTIALS=$(az ad sp create-for-rbac --name "$SP_NAME" --role "Storage Blob Data Contributor" --scopes /subscriptions/"$SUBSCRIPTION_ID" --output json)
        CLIENT_ID=$(echo "$SP_CREDENTIALS" | jq -r .appId)
        CLIENT_SECRET=$(echo "$SP_CREDENTIALS" | jq -r .password)
        TENANT_ID=$(echo "$SP_CREDENTIALS" | jq -r .tenant)
        
        echo "Service Principal $SP_NAME created."
        echo "Client ID: $CLIENT_ID"
        echo "Tenant ID: $TENANT_ID"
        echo "Client Secret: [Hidden]"
        
        # Set environment variables to use the service principal for authentication
        export AZURE_CLIENT_ID="$CLIENT_ID"
        export AZURE_TENANT_ID="$TENANT_ID"
        export AZURE_CLIENT_SECRET="$CLIENT_SECRET"
    else
        echo "Service Principal $SP_NAME already exists. Proceeding with existing credentials."
    fi
}

# Function to authenticate using the Service Principal
authenticate_with_sp() {
    echo "Authenticating with Service Principal..."
    az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" --tenant "$AZURE_TENANT_ID"
    if [ $? -ne 0 ]; then
        echo "Service Principal authentication failed. Exiting."
        exit 1
    fi
}

# Function to prompt user for input fields
get_user_input() {
    read -p "Do you want to use an existing Azure Storage account? (y/n): " choice
    case "$choice" in
        y|Y ) use_existing_account;;
        n|N ) create_storage_account;;
        * ) echo "Invalid option. Exiting."; exit 1;;
    esac
}

# Function to use an existing storage account
use_existing_account() {
    read -p "Enter your Azure resource group name: " RESOURCE_GROUP
    read -p "Enter your Azure Storage account name: " STORAGE_ACCOUNT
    read -p "Enter your Azure storage container name: " CONTAINER_NAME
    prompt_file_path
}

# Function to create a new storage account
create_storage_account() {
    read -p "Enter a new resource group name: " RESOURCE_GROUP
    az group create --name "$RESOURCE_GROUP" --location eastus
    if [ $? -ne 0 ]; then
        echo "Failed to create resource group. Exiting."
        exit 1
    fi

    read -p "Enter a new Storage account name: " STORAGE_ACCOUNT
    az storage account create --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --location eastus --sku Standard_LRS
    if [ $? -ne 0 ]; then
        echo "Failed to create storage account. Exiting."
        exit 1
    fi

    read -p "Enter a new storage container name: " CONTAINER_NAME
    az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT"
    if [ $? -ne 0 ]; then
        echo "Failed to create storage container. Exiting."
        exit 1
    fi

    prompt_file_path
}

# Function to prompt for file path and validate if file exists
prompt_file_path() {
    while true; do
        read -p "Enter the file path to upload: " FILE_PATH
        if [ -f "$FILE_PATH" ]; then
            # Check for allowed file types
            break
        else
            echo "File not found: $FILE_PATH. Please enter a valid file path."
        fi
    done
}

# Function to upload file to Azure Blob Storage
upload_file() {
    echo "Checking if the file already exists in the container..."
    az storage blob exists \
        --account-name "$STORAGE_ACCOUNT" \
        --container-name "$CONTAINER_NAME" \
        --name "$(basename "$FILE_PATH")" --output tsv | grep -q true

    if [ $? -eq 0 ]; then
        read -p "The file already exists. Do you want to overwrite it? (y/n): " choice
        case "$choice" in
            y|Y ) echo "Overwriting the file...";;
            n|N ) echo "Upload canceled."; exit 0;;
            * ) echo "Invalid option. Exiting."; exit 1;;
        esac
    fi

    echo "Uploading file..."
    az storage blob upload \
        --account-name "$STORAGE_ACCOUNT" \
        --container-name "$CONTAINER_NAME" \
        --file "$FILE_PATH" \
        --name "$(basename "$FILE_PATH")"

    if [ $? -eq 0 ]; then
        echo -e "\nFile uploaded successfully to Azure Blob Storage."
    else
        echo -e "\nFile upload failed. Exiting."
        exit 1
    fi
}

# Main script execution
check_azure_cli_installed

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_help
fi

# Prompt for subscription ID to use for role assignments
read -p "Enter your Azure Subscription ID: " SUBSCRIPTION_ID

create_service_principal
authenticate_with_sp
get_user_input
upload_file
