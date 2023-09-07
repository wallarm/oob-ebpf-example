1. Install CLI tools `brew update && brew install make azure-cli terraform`
2. Create `.env` file and place API token, refer `.env.example`
3. Login to Azure cloud `az login`
4. Deploy Terraform code and get cluster config `make all`
5. Perform attack using HTTPS schema `make attack-https`
6. Check attacks in Wallarm web interface
7. Cleanup resources `make destroy`