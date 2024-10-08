# CloudUploader-CLI 

CloudUploader CLI is a simple Bash-based tool for uploading files to Azure Blob Storage. It provides a seamless experience similar to popular cloud storage services by allowing users to upload files directly from the command line.

## Features
- Upload files to Azure Blob Storage via a simple command.
- Validation for file existence and Azure Storage credentials.
- Error handling and user feedback on successful or failed uploads.

## Prerequisites
Before you start, ensure you have the following:

1. **Azure Subscription**: You will need an active Azure account and an Azure Storage account.
2. **Azure CLI**: Install the Azure CLI to authenticate and interact with Azure Blob Storage. You can download and install it [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
3. **Bash Shell**: This script is written for Bash, which is available by default on Linux and macOS. For Windows users, use WSL or Git Bash.

## Setup

### 1. **Clone the Repository**
```bash
git clone https://github.com/ryangoeglein/CloudUploader-CLI.git
cd CloudUploader_CLI
```
### 2. **Azure Blob Storage Setup**
Make sure you have an Azure Storage account and a Blob container ready for uploads. If not, follow these steps:
- **Create an Azure Storage Account:**
  ```bash
  az storage account create --name <storage_account_name> --resource-group <resource_group> --location <location> --sku Standard_LRS
  ```
- **Create Create a Blob Container:**
  ```bash
  az storage container create --name <container_name> --account-name <storage_account_name>
  ```
### 3. **Set up Environment Variables**
To securely store your Azure credentials, you need to set environment variables for your storage account name and key.
  **Edit your** ~/.bashrc **file to add these variables:**
  ```bash
  export AZURE_STORAGE_ACCOUNT="your_storage_account_name"
  export AZURE_STORAGE_KEY="your_storage_account_key"
  ```
Once added, run the following command to apply the changes:
```bash
 source ~/.bashrc
  ```
You can verify the variables are set by running:
```bash
echo $AZURE_STORAGE_ACCOUNT
echo $AZURE_STORAGE_KEY
  ```
### 4. **Authentication**
Before running the script, authenticate to Azure using the Azure CLI:
```bash
  az login
  ```

## Usage

### Basic Command
To upload a file to Azure Blob Storage, use the following command:
```bash
  ./clouduploader.sh /path/to/file.txt
  ```
This command will upload the specified file to the blob container defined in the script.
### Example
```bash
  ./clouduploader.sh ~/Documents/report.pdf
  ```
The file report.pdf will be uploaded to your Azure Blob container.

### How It Works
1. The script checks if the file exists.
2. It ensures Azure credentials are available via environment variables.
3. It uses the Azure CLI to upload the file to the specified Blob container.
4. Provides feedback on the success or failure of the upload.

## Troubleshooting
### Common Issues:
1. **Environment Variables Not Set:**
   - Ensure that the environment variables (AZURE_STORAGE_ACCOUNT and AZURE_STORAGE_KEY) are set in your ~/.bashrc or ~/.bash_profile.
   - Check by running echo $AZURE_STORAGE_ACCOUNT and echo $AZURE_STORAGE_KEY to confirm.
2. **File Not Found:**
   - Ensure the file you are trying to upload exists and the path is correct. You can check the file's existence by running ls /path/to/file.
3. **Azure CLI Not Installed:**
   - Make sure the Azure CLI is installed and properly configured. Run az --version to verify the installation.
4. **Authentication Issues:**
   - If you're having trouble authenticating, run az login to ensure you're properly signed into your Azure account.
5. **Permission Denied Errors:**
   - If you receive permission errors when running the script, make sure the script has executable permissions:
    ```bash
    chmod +x clouduploader
    ```
## Next Steps & Future Enhancements
- Add support for optional progress bars using tools like pv.
- Provide an option to generate and display a shareable link post-upload.
- Implement file synchronization (overwrite, skip, rename).
- Encrypt files for added security before uploading.

## Contributing
Feel free to fork this repository and submit pull requests with improvements, additional features, or bug fixes.

## Licsense
This project is licensed under the MIT License - see the LICENSE file for details.









