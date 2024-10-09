# Cloud Uploader CLI Tool

CloudUploader is a command-line interface (CLI) tool designed to facilitate file uploads to Azure Blob Storage. It includes user authentication, file path validation, and options for overwriting existing files.


## Features
- Authenticate with Azure using the Azure CLI.
- Upload files to a specified Azure Blob Storage container.
- Check for existing files and prompt for overwrite.
- Display upload progress using `pv` (if available).

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

   cd CloudUploader-CLI
  ```

### 2. **Make the script executable:**
  ```bash
  chmod +x clouduploader.sh
  ```

## Environment Variables
Set the following environment variables in your terminal before running the script:
```bash
export AZURE_STORAGE_ACCOUNT="your_account_name"
export AZURE_STORAGE_KEY="your_account_key"
export AZURE_CONTAINER_NAME="your_container_name"
```

## Usage

1. Open the terminal
2. Navigate to the directory containing the script.
    ```bash
   cd CloudUploader-CLI
    ```
4. Run the script:
   ```bash
    ./clouduploader.sh
   ```
5. Follow the prompts to authenticate with Azure and upload your files


## Example
To upload a file named example.txt:
1. Make sure the environment variables are set.
2. Run the script.
3. Enter the file path when prompted.
    - **Example:** ~/Documents/report.pdf

## Next Steps & Future Enhancements
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







