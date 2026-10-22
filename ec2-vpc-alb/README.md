# AWS Infrastructure Automation Using Terraform

## 📌 Project Overview

This project demonstrates how to provision AWS infrastructure using Terraform (Infrastructure as Code).

The infrastructure includes:

- Amazon VPC
- Two subnets
- Amazon EC2 instances
- EC2 Launch Template
- Auto Scaling Group (ASG)
- Application Load Balancer (ALB)
- Target Group with health checks

The Application Load Balancer distributes incoming application traffic across healthy EC2 instances. The Auto Scaling Group manages EC2 instance capacity using the Launch Template.

Terraform automates the infrastructure deployment process, while sensitive configuration files are excluded from the GitHub repository.

## 🏗️ Architecture

```text
                       AWS Cloud
                           |
                           v
                          VPC
                           |
               Application Load Balancer
                           |
                     Listener / Rules
                           |
                      Target Group
                           |
                +----------+----------+
                |                     |
                v                     v
             Subnet 1              Subnet 2
                |                     |
                +----------+----------+
                           |
                    Auto Scaling Group
                           |
                     Launch Template
                           |
                +----------+----------+
                |                     |
                v                     v
           EC2 Instance 1         EC2 Instance 2
```

*Note: This is a conceptual architecture. The actual placement of resources depends on the Terraform configuration. For high availability, an ALB typically uses subnets in at least two Availability Zones.*

## 🛠️ Technologies Used

- **AWS VPC** – Network isolation
- **Amazon EC2** – Compute instances
- **EC2 Launch Template** – Instance launch configuration
- **Auto Scaling Group** – Instance capacity management
- **Application Load Balancer** – Traffic distribution
- **Target Group** – Target registration and health checks
- **Terraform** – Infrastructure as Code
- **Git and GitHub** – Version control and documentation

## ☁️ AWS Resources

### 1. Virtual Private Cloud (VPC)

Creates an isolated network environment for the AWS infrastructure.

### 2. Subnets

Creates two subnets to organize resources within the VPC. The subnets can be configured in different Availability Zones for improved availability.

### 3. Amazon EC2

EC2 instances provide the compute capacity required to run the application.

### 4. EC2 Launch Template

Defines the configuration used to launch EC2 instances, including:

- Amazon Machine Image (AMI) ID
- EC2 instance type
- EC2 key pair name

### 5. Auto Scaling Group (ASG)

The Auto Scaling Group manages EC2 instance capacity using the Launch Template.

Depending on its configuration, it can:

- Maintain the desired number of EC2 instances.
- Replace unhealthy instances.
- Launch instances in configured subnets.
- Scale capacity according to configured scaling policies.

### 6. Application Load Balancer (ALB)

The Application Load Balancer receives incoming HTTP or HTTPS requests and distributes traffic across registered, healthy targets.

### 7. Target Group

The Target Group registers EC2 instances and performs health checks to determine which instances are healthy enough to receive traffic.

## 📂 Project Structure

```text
terraform-aws-infrastructure/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── .gitignore
└── README.md
```

**Note:** The `terraform.tfvars` file is intentionally excluded from this repository for security reasons.

| File | Description |
|---|---|
| `main.tf` | Defines AWS resources |
| `variables.tf` | Declares Terraform input variables |
| `outputs.tf` | Defines useful infrastructure outputs |
| `provider.tf` | Configures the AWS provider and region |
| `.gitignore` | Excludes local and sensitive files |
| `README.md` | Documents the project |

*Your actual file structure may differ depending on your Terraform configuration.*

## ⚙️ Prerequisites

Before deploying the infrastructure, ensure you have:

1. An AWS account.
2. Terraform installed.
3. AWS CLI installed and configured, or another supported AWS credentials method.
4. Appropriate IAM permissions to create the required resources.
5. A valid AMI ID for your selected AWS region.
6. An existing EC2 key pair in that region.

### Verify Terraform Installation

```bash
terraform -version
```

### Configure AWS Credentials

```bash
aws configure
```

Alternatively, use an IAM role or environment variables to provide AWS credentials.

**Security reminder:** Never hardcode AWS access keys in Terraform configuration files.

## 🔐 Configuration and Security

The `terraform.tfvars` file contains environment-specific configuration values, such as:

- AMI ID
- EC2 instance type
- EC2 key pair name

For security reasons, **`terraform.tfvars` is not uploaded to GitHub**.

Anyone cloning this repository must create their own local `terraform.tfvars` file before deploying the infrastructure.

### Example `terraform.tfvars`

Create a file named `terraform.tfvars` in the project root directory.

```hcl
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t2.micro"
key_name      = "your-key-pair-name"
```

Replace the example values with valid values for your AWS environment.

**Important:**
- Use an AMI ID valid in your selected AWS region.
- Choose an instance type supported in your region and account.
- Use an existing EC2 key pair name.
- Never upload private SSH keys, AWS credentials, or other secrets to GitHub.
- Ensure the variable names match those declared in `variables.tf`.

### Example `.gitignore`

```gitignore
# Terraform working directory
.terraform/

# Terraform state files
*.tfstate
*.tfstate.*

# Terraform variable files
terraform.tfvars
terraform.tfvars.json
*.auto.tfvars
*.auto.tfvars.json

# Terraform crash logs
crash.log
crash.*.log

# Terraform override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Private keys
*.pem
*.key
```

**Important:** Terraform state files may contain sensitive information and should not be committed to GitHub.

Adding a file to `.gitignore` does not remove it from Git history if it was committed previously. If secrets were exposed, remove them from tracking and rotate the affected credentials.

## 🚀 Deployment Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR-USERNAME/YOUR-REPOSITORY.git
```

Navigate to the project directory:

```bash
cd YOUR-REPOSITORY
```

Replace the example URL with your actual GitHub repository URL.

### Step 2: Create the Variables File

Create your local `terraform.tfvars` file in the project root.

Example:

```hcl
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t2.micro"
key_name      = "your-key-pair-name"
```

Update the values according to your AWS environment.

Do not upload this file to GitHub.

### Step 3: Initialize Terraform

```bash
terraform init
```

This initializes the Terraform working directory and downloads the required provider plugins.

### Step 4: Format and Validate

```bash
terraform fmt -recursive
terraform validate
```

These commands format the Terraform configuration and validate its syntax and structure.

### Step 5: Review the Execution Plan

```bash
terraform plan
```

Review the proposed changes before creating AWS resources.

### Step 6: Deploy the Infrastructure

```bash
terraform apply
```

Review the execution plan and confirm when prompted.

Terraform will provision the resources defined in your configuration.

### Step 7: Verify the AWS Resources

Open the AWS Management Console and verify the following:

1. **VPC:** Check the VPC and two subnets.
2. **EC2 Instances:** Verify the launched instances.
3. **Launch Templates:** Check the EC2 launch configuration.
4. **Auto Scaling Groups:** Verify the ASG and its capacity settings.
5. **Load Balancers:** Verify that the ALB is active.
6. **Target Groups:** Check target registration and health status.

You can also inspect your instances and Auto Scaling Groups using the AWS CLI:

```bash
aws ec2 describe-instances
```

```bash
aws autoscaling describe-auto-scaling-groups
```

These commands use your configured AWS credentials and region.

## 🔄 How Traffic Flows

1. A client sends an HTTP or HTTPS request to the ALB DNS name.
2. The ALB listener receives the request.
3. Listener rules forward the request to the configured Target Group.
4. The Target Group routes traffic to registered, healthy EC2 instances.
5. The Auto Scaling Group manages instance capacity according to its configuration.
6. The Launch Template defines the configuration for newly launched instances.

For this traffic flow to work, the ALB listener, Target Group, health checks, routing, and security groups must be configured correctly.

For example, the EC2 security group should allow the application traffic from the ALB security group.

## 🌐 Testing the Application Load Balancer

1. Open the AWS Management Console.
2. Navigate to **EC2 → Load Balancers**.
3. Select your Application Load Balancer.
4. Copy its DNS name.
5. Navigate to **Target Groups** and check target health.
6. Open the ALB DNS name in your browser using the appropriate protocol and application path.

The application will be accessible only if the listeners, security groups, networking, target health, and application configuration are correct.

## 📈 Auto Scaling Group

The Auto Scaling Group uses the Launch Template to launch EC2 instances.

Depending on the configuration, it can:

- Maintain a desired instance count.
- Replace unhealthy instances.
- Launch instances across configured subnets.
- Increase or decrease capacity using scaling policies.

Actual scaling behavior depends on the minimum, maximum, and desired capacities, health checks, and scaling policies configured in Terraform.

## 🧹 Destroy Infrastructure

When you no longer need the infrastructure, run:

```bash
terraform destroy
```



## 🎯 Learning Outcomes

This project demonstrates practical experience with:

- Infrastructure as Code using Terraform.
- AWS VPC and subnet configuration.
- EC2 instance provisioning.
- EC2 Launch Templates.
- Auto Scaling Groups.
- Application Load Balancers.
- Target Groups and health checks.
- Traffic distribution across EC2 instances.
- Terraform variables and configuration management.
- GitHub version control and security practices.



## 👨‍💻 Author

NIKHIL

GitHub: [kvnikhildev](https://github.com/kvnikhildev)

