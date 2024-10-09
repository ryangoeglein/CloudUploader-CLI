#!/bin/bash

# Function to check if Azure CLI is installed
check_azure_cli_installed() {
    if ! command -v az &> /dev/null; then
        echo "Azure CLI is not installed. Please install it from: https://aka.ms/InstallAzureCli"
        exit 1
    fi
}

# Function to prompt user to authenticate with Azure
authenticate_azure() {
    echo "Please authenticate with Azure CLI..."
    az login
    if [ $? -ne 0 ]; then
        echo "Azure authentication failed. Exiting."
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
    read -sp "Enter your Azure Storage account access key: " STORAGE_KEY
    echo
    read -p "Enter your Azure storage container name: " CONTAINER_NAME
    prompt_file_path
}

# Function to create a new storage account
create_storage_account() {
    read -p "Enter a new resource group name: " RESOURCE_GROUP
    az group create --name "$RESOURCE_GROUP" --location eastus

    read -p "Enter a new Storage account name: " STORAGE_ACCOUNT
    az storage account create --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --location eastus --sku Standard_LRS

    STORAGE_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP" --account-name "$STORAGE_ACCOUNT" --query '[0].value' --output tsv)

    read -p "Enter a new storage container name: " CONTAINER_NAME
    az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT" --account-key "$STORAGE_KEY"

    prompt_file_path
}

# Function to prompt for file path and validate if file exists
prompt_file_path() {
    while true; do
        read -p "Enter the file path to upload: " FILE_PATH
        if [ -f "$FILE_PATH" ]; then
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
        --account-key "$STORAGE_KEY" \
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

    # Show progress bar during upload
    echo "Uploading file..."
    
    # Use 'pv' to show progress (make sure pv is installed)
    {
        echo "Starting upload..."
        az storage blob upload \
            --account-name "$STORAGE_ACCOUNT" \
            --account-key "$STORAGE_KEY" \
            --container-name "$CONTAINER_NAME" \
            --file "$FILE_PATH" \
            --name "$(basename "$FILE_PATH")" --output table
    } | pv -s $(du -b "$FILE_PATH" | awk '{print $1}') > /dev/null

    if [ $? -eq 0 ]; then
        echo -e "\nFile uploaded successfully to Azure Blob Storage."
    else
        echo -e "\nFile upload failed. Exiting."
        exit 1
    fi

    # Ask if the user wants to upload another file
    upload_more_files
}

# Function to prompt user for uploading more files
upload_more_files() {
    read -p "Would you like to upload another file? (y/n): " choice
    case "$choice" in
        y|Y ) prompt_file_path; upload_file;;
        n|N ) echo "Exiting."; exit 0;;
        * ) echo "Invalid option. Exiting."; exit 1;;
    esac
}

# Main script starts here

# Step 1: Check if Azure CLI is installed
check_azure_cli_installed

# Step 2: Authenticate with Azure
authenticate_azure

# Step 3: Get user input for Azure configuration
get_user_input

# Step 4: Upload file to Azure Blob Storage
upload_file
