#!/bin/bash

# Function to display help
display_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help            Show this help message."
    echo "  -a, --account         Use an existing Azure Storage account."
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

# Function to check if required environment variables are set
check_environment_variables() {
    if [[ -z "$AZURE_STORAGE_ACCOUNT" || -z "$AZURE_STORAGE_KEY" || -z "$AZURE_CONTAINER_NAME" ]]; then
        echo "Required environment variables (AZURE_STORAGE_ACCOUNT, AZURE_STORAGE_KEY, AZURE_CONTAINER_NAME) are not set."
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

# Function to use an existing storage account from environment variables
use_existing_account() {
    STORAGE_ACCOUNT="$AZURE_STORAGE_ACCOUNT"
    STORAGE_KEY="$AZURE_STORAGE_KEY"
    CONTAINER_NAME="$AZURE_CONTAINER_NAME"
    
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

# Function to upload file to Azure Blob Storage with progress
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

    # Show upload progress using 'pv'
    echo "Uploading file..."
    FILE_SIZE=$(stat -c %s "$FILE_PATH")
    if command -v pv &> /dev/null; then
        {
            az storage blob upload \
                --account-name "$STORAGE_ACCOUNT" \
                --account-key "$STORAGE_KEY" \
                --container-name "$CONTAINER_NAME" \
                --file "$FILE_PATH" \
                --name "$(basename "$FILE_PATH")" --output table
        } | pv -s "$FILE_SIZE" > /dev/null
    else
        az storage blob upload \
            --account-name "$STORAGE_ACCOUNT" \
            --account-key "$STORAGE_KEY" \
            --container-name "$CONTAINER_NAME" \
            --file "$FILE_PATH" \
            --name "$(basename "$FILE_PATH")" --output table
    fi

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

# Cleanup function to run on exit
cleanup() {
    echo "Cleaning up..."
    # Perform any necessary cleanup actions here (e.g., deleting temporary files)
}

# Trap to ensure cleanup happens on exit
trap cleanup EXIT

# Main script execution
check_azure_cli_installed
check_environment_variables
authenticate_azure
use_existing_account
