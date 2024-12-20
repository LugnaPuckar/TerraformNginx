# Terraform
## NGINX Deployment on Azure, AWS, and GCP  

This project demonstrates the use of **Terraform** for automating Infrastructure as Code (IaC) deployments. The goal is to deploy and manage **NGINX servers** on virtual machines (VMs) across **Microsoft Azure**, **Amazon Web Services (AWS)**, and **Google Cloud Platform (GCP)**.

## Features  
- Automated deployment of VMs with NGINX installed.  
- Platform-independent Terraform configurations for Azure, AWS, and GCP.  
- Bash menu for simplified deployment and teardown workflows.  

## Prerequisites  
1. **Accounts** on Azure, AWS, and GCP.  
2. Installed CLIs:  
   - [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)  
   - [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)  
   - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)  
   - [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)  
3. Terraform and platform-specific credentials configured:  
   - Azure Subscription ID  
   - AWS Access and Secret Keys  
   - GCP Project ID  
4. AWS `.pem` key file:  
   - Generate a key pair in the AWS Management Console.  
   - Save the private key (`.pem`) securely.  
   - Add the path to the `.pem` file in your Terraform AWS module or configuration.  

## Setup  
1. Clone the repository:  
   ```bash  
   git clone https://github.com/LugnaPuckar/TerraformNginx.git  
   cd TerraformNginx  
   ```  
2. Add your subscription/project IDs to `.txt` files under the `cloud_secrets/` directory:  
   - `azure_subscription_id.txt`  
   - `gcp_project_id.txt`  

3. Configure the **AWS `.pem` file**:  
   - Run the following CMD in `cloud_secrets/´ directory. If you already have a .pem key on AWS named ``AwsNginxKey`` then you can skip this step unless you want to SSH in to the AWS VM.
   - aws ec2 create-key-pair --key-name AwsNginxKey --query "KeyMaterial" --output text > AwsNginxKey.pem
   - chmod 600 AwsNginxKey.pem
 

## Usage  
Run the **Bash Menu** to deploy or destroy configurations:  
```bash  
bash main_menu.sh  
```  
Options include:  
- Deploy to a specific platform (Azure, AWS, or GCP).  
- Deploy to all platforms simultaneously.  
- Destroy resources on a specific or all platforms.  

## Notes  
- All `.txt` and `.pem` files in `cloud_secrets/` are `.gitignored` for security.  
- Modularization is simplified for learning purposes.
- Be aware of incurred costs to cloud platforms.
- Don't forget to destroy and remove when done to avoid extra costs.

## License  
This project is licensed under the MIT License.  

---  
Happy automating! 🚀  
```
