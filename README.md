# CloudUploader CLI Tool

CloudUploader is a command-line interface (CLI) tool designed to facilitate file uploads to Azure Blob Storage. This script allows users to quickly and easily upload files, either using an existing Azure Storage account or by creating a new one directly from the command line.

## Features
- **User-friendly prompts** for configuration and file uploads.
- **Progress bar** for monitoring upload status.
- **Supports multiple uploads** without restarting the script.
- **Cross-platform compatibility** with Linux and macOS.
- **Azure CLI integration** for seamless interaction with Azure Blob Storage.

## Prerequisites
Before you start, ensure you have the following:

1. **Azure Subscription**: You will need an active Azure account and an Azure Storage account.
2. **Azure CLI**: Ensure you have the Azure CLI installed. Follow the installation instructions at [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).
3. **Bash Shell**: This script is written for Bash, which is available by default on Linux and macOS. For Windows users, use WSL or Git Bash.
4. **pv**: This tool is required for displaying upload progress. Install it using your package manager:
   - **Debian/Ubuntu**: sudo apt install pv
   - **Red Hat/CentOS**: sudo yum install pv
   - **macOS**: brew install pv


## Installation

### 1. **Clone the Repository**
  ```bash
  git clone https://github.com/ryangoeglein/CloudUploader-CLI.git
  cd CloudUploader_CLI
  ```
### 2. **Azure Blob Storage Setup**
  Download or copy the clouduploader.sh script to your local machine (should have it accessible if you clone the repository)

### 3. **Make the script executable:**
  ```bash
  chmod +x clouduploader.sh
  ```

## Usage

1. Open the terminal
2. Run the script:
   ```bash
    ./clouduploader.sh
   ```
3. Follow the prompts to authenticate with Azure and upload your files.
4. When prompted for the file path, be sure to provide the path & filename.
   - **Example:** ~/Documents/report.pdf

## Configuration
During the execution of the script, you will be prompted for the following information:
- **Azure Resource Group:** The name of your Azure resource group.
- **Storage Account Name:** The name of your existing or new Azure Storage account.
- **Storage Container Name:** The name of the container in which you want to upload the files.
- **File Path:** The local path of the file you wish to upload.

## Examples
### Uploading a File to an Existing Storage Account
1. Choose to use an existing Azure Storage account when prompted.
2. Provide the necessary information.
3. Enter the file path to upload.

### Creating a New Storage Account
1. Choose to create a new Azure Storage account when prompted.
2. Follow the prompts to set up the resource group, storage account, and container.
3. Enter the file path to upload.
## Next Steps & Future Enhancements
- Add support for optional progress bars using tools like pv.
- Provide an option to generate and display a shareable link post-upload.
- Implement file synchronization (overwrite, skip, rename).
- Encrypt files for added security before uploading.

## Contributing
Contributions are welcome! If you have suggestions for improvements or new features, feel free to submit an issue or a pull request.

## Licsense
This project is licensed under the MIT License - see the [LICENSE](https://github.com/ryangoeglein/CloudUploader-CLI/blob/eb6e8b0e21e962a2504d65e442f0a54887f4c346/License) file for details.

## Acknowledgments
- [Learn to Cloud](https://learntocloud.guide/phase1/)
- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [Pipe Viewer (pv) Documentation](https://www.ivarch.com/programs/quickref/pv.shtml)







