#!/bin/bash

# Check if a file argument is passed
if [ -z "$1" ]; then
    echo "Usage: clouduploader /path/to/file"
    exit 1
fi

# Get the file path
FILE_PATH=$1

# Ensure Azure storage account and key are set
if [ -z "$AZURE_STORAGE_ACCOUNT" ] || [ -z "$AZURE_STORAGE_KEY" ]; then
    echo "Azure Storage credentials are not set. Please configure environment variables."
    exit 1
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "File not found: $FILE_PATH"
    exit 1
fi

# Define the blob container
CONTAINER_NAME="file-uploader-container"

# Check if the file exists in the cloud
az storage blob exists \
    --account-name $AZURE_STORAGE_ACCOUNT \
    --account-key $AZURE_STORAGE_KEY \
    --container-name $CONTAINER_NAME \
    --name "$(basename "$FILE_PATH")"

# Prompt for overwriting if file exists
if [ $? -eq 0 ]; then
    read -p "File is currently within Azure Blob Storage. Would you like to upload? (y/n): " choice
    case "$choice" in 
      y|Y ) echo "Uploading now...";;
      n|N ) echo "Skipping upload."; exit 0;;
      * ) echo "Invalid option. Exiting."; exit 1;;
    esac
fi

# Upload file to Azure Blob Storage
az storage blob upload \
    --account-name $AZURE_STORAGE_ACCOUNT \
    --account-key $AZURE_STORAGE_KEY \
    --container-name $CONTAINER_NAME \
    --file "$FILE_PATH" \
    --name "$(basename "$FILE_PATH")"

# Check if the upload was successful
if [ $? -eq 0 ]; then
    echo "File uploaded successfully to Azure Blob Storage."
else
    echo "Failed to upload file."
    exit 1
fi

