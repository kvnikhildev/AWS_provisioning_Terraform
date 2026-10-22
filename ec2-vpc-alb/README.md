# AWS Infrastructure Automation Using Terraform

## 📌 Project Overview

This project demonstrates how to provision AWS infrastructure using Terraform (Infrastructure as Code).

The infrastructure includes a Virtual Private Cloud (VPC), two subnets, EC2 instances, an EC2 Launch Template, and an Auto Scaling Group.

The goal of this project is to automate AWS infrastructure deployment while following basic security practices by keeping sensitive configuration values out of the GitHub repository.

## 🏗️ Architecture

The project provisions the following AWS resources:

- **VPC:** A dedicated Virtual Private Cloud to isolate the infrastructure.
- **Subnets:** Two subnets to distribute resources across separate network segments.
- **EC2 Instances:** Compute instances deployed within the VPC.
- **Launch Template:** Defines the EC2 instance configuration, including the AMI ID, instance type, and SSH key pair.
- **Auto Scaling Group (ASG):** Manages EC2 instance capacity using the launch template.

### Architecture Flow

```text
                    AWS Cloud
                        |
                        v
                       VPC
                        |
              +---------+---------+
              |                   |
              v                   v
          Subnet 1             Subnet 2
              |                   |
              +---------+---------+
                        |
                        v
                Launch Template
                        |
                        v
                Auto Scaling Group
                        |
                +-------+-------+
                |               |
                v               v
             EC2 Instance  EC2 Instance
```

*Note: This is a conceptual diagram. The actual subnet placement and resource relationships depend on your Terraform configuration.*

## 🛠️ Technologies Used

- **Amazon Web Services (AWS)**
  - Amazon VPC
  - Amazon EC2
  - EC2 Launch Templates
  - Auto Scaling Groups
  - Subnets
- **Terraform:** Infrastructure provisioning and management.
- **Git and GitHub:** Version control and project documentation.

## 📂 Project Structure

```text
terraform-aws-infrastructure/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars        # Not uploaded to GitHub
├── .gitignore
└── README.md
```

*The file structure may vary depending on your actual Terraform configuration.*

### File Descriptions

| File | Description |
|---|---|
| `main.tf` | Defines AWS resources such as the VPC, subnets, EC2 instances, launch template, and Auto Scaling Group. |
| `variables.tf` | Declares input variables used to configure the infrastructure. |
| `outputs.tf` | Defines useful outputs, such as resource IDs and other infrastructure details. |
| `provider.tf` | Configures the AWS provider and region. |
| `terraform.tfvars` | Supplies variable values, including the AMI ID, instance type, and key pair name. This file is excluded from GitHub. |
| `.gitignore` | Prevents Terraform state files, variable files, and other sensitive or unnecessary files from being committed. |

## ⚙️ Prerequisites

Before deploying this infrastructure, ensure you have:

1. An AWS account.
2. Terraform installed on your local machine.
3. AWS CLI installed and configured.
4. Appropriate AWS IAM permissions to create the required resources.
5. An existing EC2 key pair in the selected AWS region.
6. A valid AMI ID for the selected AWS region.

### Verify Terraform Installation

```bash
terraform -version
```

### Configure AWS Credentials

Configure your AWS credentials using the AWS CLI:

```bash
aws configure
```

Alternatively, use an IAM role or environment variables to provide AWS credentials.

Avoid hardcoding AWS access keys in Terraform files.

## 🔐 Configuration and Security

The `terraform.tfvars` file contains environment-specific configuration values, such as:

- AMI ID
- EC2 instance type
- EC2 key pair name

For security and configuration management purposes, **`terraform.tfvars` is intentionally excluded from this GitHub repository**.

Users must create their own local `terraform.tfvars` file before deploying the infrastructure.

### Example `terraform.tfvars`

Create a file named `terraform.tfvars` in the project root directory.

```hcl
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t2.micro"
key_name      = "your-key-pair-name"
```

Replace the example values with valid values for your AWS environment.

**Important:**
- Use an AMI ID that is valid in your selected AWS region.
- Choose an instance type supported by your AWS account and region.
- Use an existing EC2 key pair name.
- Never upload private SSH keys, AWS credentials, or other secrets to GitHub.
- Do not commit Terraform state files, which may contain sensitive information.

The variable names in this example must match the variable declarations in `variables.tf`. Adjust them if your configuration uses different names.

### Example `.gitignore`

Ensure your `.gitignore` includes entries similar to these:

```gitignore
# Terraform working directory
.terraform/

# Terraform state files
*.tfstate
*.tfstate.*
crash.log
crash.*.log

# Variable files
terraform.tfvars
terraform.tfvars.json
*.auto.tfvars
*.auto.tfvars.json

# Terraform override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Sensitive local files
*.pem
*.key
```

Review the ignore patterns to ensure they match your team's workflow and do not exclude files that must be version-controlled.

**Note:** If `terraform.tfvars` was committed previously, adding it to `.gitignore` does not remove it from Git history. Remove it from tracking and rotate any credentials that were exposed.

## 🚀 Deployment Steps

Follow these steps to deploy the infrastructure.

### Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
```

Navigate to the project directory:

```bash
cd YOUR-REPOSITORY
```

Replace the example GitHub URL with your repository URL.

### Step 2: Create the Variables File

Create your local `terraform.tfvars` file and configure the required values.

For example:

```hcl
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t2.micro"
key_name      = "your-key-pair-name"
```

Do not upload this file to GitHub.

### Step 3: Initialize Terraform

```bash
terraform init
```

This initializes the Terraform working directory and downloads the required provider plugins.

### Step 4: Validate the Configuration

```bash
terraform validate
```

This checks whether the Terraform configuration is syntactically valid.

### Step 5: Review the Execution Plan

```bash
terraform plan
```

Review the proposed changes before creating AWS resources.

### Step 6: Deploy the Infrastructure

```bash
terraform apply
```

Review the plan and confirm the operation when prompted.

Terraform will provision the resources defined in your configuration.

### Step 7: Verify the Resources

Open the AWS Management Console and verify the resources:

1. Navigate to **VPC** and check the created VPC and subnets.
2. Navigate to **EC2 → Instances** and verify the instances.
3. Navigate to **EC2 → Launch Templates** and check the launch template.
4. Navigate to **EC2 → Auto Scaling Groups** and verify the Auto Scaling Group configuration.

You can also use the AWS CLI to inspect your resources.

For example:

```bash
aws ec2 describe-instances
```

```bash
aws autoscaling describe-auto-scaling-groups
```

## 📈 Auto Scaling Group

The Auto Scaling Group uses the EC2 Launch Template to define how new instances are launched.

Depending on its configuration, the Auto Scaling Group can:

- Maintain a desired number of EC2 instances.
- Launch replacement instances when existing instances become unhealthy.
- Increase or decrease capacity according to configured scaling policies.
- Distribute instances across multiple subnets when configured to do so.

The actual scaling behavior depends on the desired capacity, minimum and maximum capacity, health checks, and scaling policies defined in Terraform.

## 🧹 Destroy Infrastructure

To remove the infrastructure created by Terraform, run:

```bash
terraform destroy
```

Review the proposed changes and confirm when prompted.

**Warning:** This command destroys the resources managed by the Terraform configuration. Make sure you do not need those resources before proceeding.

## 🎯 Learning Outcomes

This project demonstrates practical experience with:

- Infrastructure as Code using Terraform.
- AWS VPC and subnet configuration.
- EC2 instance provisioning.
- EC2 Launch Template configuration.
- Auto Scaling Group deployment.
- Terraform input variables and configuration management.
- GitHub version control and repository documentation.
- Basic security practices for protecting configuration files.

## 🔮 Future Improvements

Possible enhancements include:

- Add public and private subnet separation.
- Configure Internet Gateway and NAT Gateway where required.
- Add security groups with least-privilege access.
- Configure an Application Load Balancer.
- Implement CPU-based scaling policies.
- Add CloudWatch monitoring and alarms.
- Store Terraform state remotely using an S3 backend with appropriate state locking.
- Introduce separate development, staging, and production environments.

## 👨‍💻 Author

**Your Name**

GitHub: [YOUR-USERNAME](https://github.com/YOUR-USERNAME)

## 📄 License

This project is available for educational and portfolio purposes. Add an appropriate open-source license if you intend to grant others permission to use, modify, and distribute the code.
