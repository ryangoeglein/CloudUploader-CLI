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
            if [[ "$FILE_PATH" != *.txt && 
                  "$FILE_PATH" != *.jpg && 
                  "$FILE_PATH" != *.jpeg && 
                  "$FILE_PATH" != *.png && 
                  "$FILE_PATH" != *.gif && 
                  "$FILE_PATH" != *.bmp && 
                  "$FILE_PATH" != *.tiff && 
                  "$FILE_PATH" != *.pdf && 
                  "$FILE_PATH" != *.doc && 
                  "$FILE_PATH" != *.docx && 
                  "$FILE_PATH" != *.xls && 
                  "$FILE_PATH" != *.xlsx && 
                  "$FILE_PATH" != *.ppt && 
                  "$FILE_PATH" != *.pptx && 
                  "$FILE_PATH" != *.zip && 
                  "$FILE_PATH" != *.tar && 
                  "$FILE_PATH" != *.gz && 
                  "$FILE_PATH" != *.rar && 
                  "$FILE_PATH" != *.7z && 
                  "$FILE_PATH" != *.mp3 && 
                  "$FILE_PATH" != *.wav && 
                  "$FILE_PATH" != *.aac && 
                  "$FILE_PATH" != *.flac && 
                  "$FILE_PATH" != *.ogg && 
                  "$FILE_PATH" != *.mp4 && 
                  "$FILE_PATH" != *.avi && 
                  "$FILE_PATH" != *.mov && 
                  "$FILE_PATH" != *.wmv && 
                  "$FILE_PATH" != *.mkv && 
                  "$FILE_PATH" != *.json && 
                  "$FILE_PATH" != *.xml && 
                  "$FILE_PATH" != *.csv && 
                  "$FILE_PATH" != *.html && 
                  "$FILE_PATH" != *.css && 
                  "$FILE_PATH" != *.js ]]; then
                echo "Invalid file type: $FILE_PATH. Allowed types are .txt, .jpg, .jpeg, .png, .gif, .bmp, .tiff, .pdf, .doc, .docx, .xls, .xlsx, .ppt, .pptx, .zip, .tar, .gz, .rar, .7z, .mp3, .wav, .aac, .flac, .ogg, .mp4, .avi, .mov, .wmv, .mkv, .json, .xml, .csv, .html, .css, .js"
                continue
            fi
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

    # Show progress bar during upload
    echo "Uploading file..."

    # Use 'stat' to get the file size in bytes, with OS compatibility
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        FILE_SIZE=$(stat -c %s "$FILE_PATH")
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        FILE_SIZE=$(stat -f %z "$FILE_PATH")
    else
        echo "Unsupported OS type: $OSTYPE"
        exit 1
    fi

    # Check for 'pv' command
    if ! command -v pv &> /dev/null; then
        echo "pv command not found. Uploading without progress display."
        # Use 'az storage blob upload' directly without 'pv'
        az storage blob upload \
            --account-name "$STORAGE_ACCOUNT" \
            --container-name "$CONTAINER_NAME" \
            --file "$FILE_PATH" \
            --name "$(basename "$FILE_PATH")" --output table
    else
        # Use 'pv' to show progress
        {
            echo "Starting upload..."
            az storage blob upload \
                --account-name "$STORAGE_ACCOUNT" \
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

    # Ask if the user wants to upload another file
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
authenticate_azure
get_user_input
upload_file
