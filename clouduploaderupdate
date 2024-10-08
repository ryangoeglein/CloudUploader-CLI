#!/bin/bash

# Check if a file argument is passed
if [ -z "$1" ]; then
    echo "Usage: clouduploaderupdate /path/to/file"
    exit 1
fi

# Get the file path
FILE_PATH=$1

# Ensure the file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "File not found: $FILE_PATH"
    exit 1
fi

# Prompt the user for Azure Storage account details
read -p "Enter your Azure Storage Account Name: " AZURE_STORAGE_ACCOUNT

# Securely prompt for the Azure Storage Account Key (hidden input)
read -sp "Enter your Azure Storage Account Key: " AZURE_STORAGE_KEY
echo  # Adds a new line after the hidden input

# Prompt the user for Azure Blob container name
read -p "Enter your Azure Blob Container Name: " CONTAINER_NAME

# Check if the file already exists in the Azure Blob container
az storage blob exists \
    --account-name "$AZURE_STORAGE_ACCOUNT" \
    --account-key "$AZURE_STORAGE_KEY" \
    --container-name "$CONTAINER_NAME" \
    --name "$(basename "$FILE_PATH")" &>/dev/null

# Check the result of the blob existence check
if [ $? -eq 0 ]; then
    read -p "Upload file to Azure Blob Storage. Confirm? (y/n): " choice
    case "$choice" in 
      y|Y ) echo "Uploading now...";;
      n|N ) echo "Skipping upload."; exit 0;;
      * ) echo "Invalid option. Exiting."; exit 1;;
    esac
fi

# Upload the file to Azure Blob Storage
az storage blob upload \
    --account-name "$AZURE_STORAGE_ACCOUNT" \
    --account-key "$AZURE_STORAGE_KEY" \
    --container-name "$CONTAINER_NAME" \
    --file "$FILE_PATH" \
    --name "$(basename "$FILE_PATH")"

# Check if the upload was successful
if [ $? -eq 0 ]; then
    echo "File uploaded successfully to Azure Blob Storage."
else
    echo "Failed to upload file."
    exit 1
fi
