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
git clone https://github.com/yourusername/clouduploader.git
cd clouduploader
