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

# Function to prompt user to authenticate with Azure
authenticate_azure() {
    echo "Authenticating with Azure..."
    az login
    if [ $? -ne 0 ]; then
        echo "Azure authentication failed. Exiting."
        exit 1
    fi
}

# Function to prompt user for input fields (existing or new account)
get_user_input() {
    read -p "Do you want to use an existing Azure Storage account? (y/n): " choice
    case "$choice" in
        y|Y ) use_existing_account;;
        n|N ) create_storage_account;;
        * ) echo "Invalid option. Exiting."; exit 1;;
    esac
}

# Function to use an existing storage account from environment variables
use_existing_account() {
    # Read sensitive information from environment variables
    if [[ -z "$AZURE_STORAGE_ACCOUNT" || -z "$AZURE_STORAGE_KEY" || -z "$AZURE_CONTAINER_NAME" ]]; then
        echo "Required environment variables (AZURE_STORAGE_ACCOUNT, AZURE_STORAGE_KEY, AZURE_CONTAINER_NAME) are not set."
        exit 1
    fi

    STORAGE_ACCOUNT="$AZURE_STORAGE_ACCOUNT"
    STORAGE_KEY="$AZURE_STORAGE_KEY"
    CONTAINER_NAME="$AZURE_CONTAINER_NAME"
    
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

    STORAGE_KEY=$(az storage account keys list --account-name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" --query '[0].value' --output tsv)

    read -p "Enter a new storage container name: " CONTAINER_NAME
    az storage container create --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT" --account-key "$STORAGE_KEY"
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
            break
        else
            echo "File not found: $FILE_PATH. Please enter a valid file path."
        fi
    done

    upload_file
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

    # Use 'az storage blob upload' to upload the file
    echo "Uploading file..."
    az storage blob upload \
        --account-name "$STORAGE_ACCOUNT" \
        --account-key "$STORAGE_KEY" \
        --container-name "$CONTAINER_NAME" \
        --file "$FILE_PATH" \
        --name "$(basename "$FILE_PATH")" --output table

    if [ $? -eq 0 ]; then
        echo -e "\nFile uploaded successfully to Azure Blob Storage."
    else
        echo -e "\nFile upload failed. Exiting."
        exit 1
    fi

    upload_more_files
}

# Function to ask if the user wants to upload more files
upload_more_files() {
    read -p "Do you want to upload another file? (y/n): " choice
    case "$choice" in
        y|Y ) prompt_file_path;;
        n|N ) echo "Exiting script."; exit 0;;
        * ) echo "Invalid option. Exiting."; exit 1;;
    esac
}

# Main script execution
check_azure_cli_installed
get_user_input
