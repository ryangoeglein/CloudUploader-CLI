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

# Function to prompt user to authenticate with Azure
authenticate_azure() {
    echo "Authenticating with Azure..."
    az login
    if [ $? -ne 0 ]; then
        echo "Azure authentication failed. Exiting."
        exit 1
    fi
}

# Function to prompt user for input fields for existing account
get_user_input() {
    use_existing_account
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

    # Get the file size based on OS compatibility
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        FILE_SIZE=$(stat -c %s "$FILE_PATH")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        FILE_SIZE=$(stat -f %z "$FILE_PATH")
    else
        echo "Unsupported OS type: $OSTYPE"
        exit 1
    fi

    # Check if FILE_SIZE was set successfully
    if [[ -z "$FILE_SIZE" ]]; then
        echo "Failed to retrieve file size. Exiting."
        exit 1
    fi

    # Check for 'pv' command
    if ! command -v pv &> /dev/null; then
        echo "pv command not found. Uploading without progress display."
        # Use 'az storage blob upload' directly without 'pv'
        az storage blob upload \
            --account-name "$STORAGE_ACCOUNT" \
            --account-key "$STORAGE_KEY" \
            --container-name "$CONTAINER_NAME" \
            --file "$FILE_PATH" \
            --name "$(basename "$FILE_PATH")" --output table
    else
        # Use 'pv' to show progress
        {
            az storage blob upload \
                --account-name "$STORAGE_ACCOUNT" \
                --account-key "$STORAGE_KEY" \
                --container-name "$CONTAINER_NAME" \
                --file "$FILE_PATH" \
                --name "$(basename "$FILE_PATH")" --output table
        } | pv -s "$FILE_SIZE" > /dev/null
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

# Main script execution
check_azure_cli_installed
get_user_input
