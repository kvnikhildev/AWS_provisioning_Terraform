# AWS VPC Peering Using Terraform

## 📌 Project Overview

This project demonstrates how to establish private network communication between two Amazon Virtual Private Clouds (VPCs) using **AWS VPC Peering and Terraform**.

Two VPCs are created, with a subnet and an EC2 instance in each VPC. A VPC peering connection is established between the VPCs, and route tables and security groups are configured to allow communication between the instances using their private IP addresses.

I verified the connectivity by logging into an EC2 instance and using the `curl` command to communicate with the EC2 instance in the other VPC.

Terraform is used to automate the infrastructure deployment process. The `terraform.tfvars` file is excluded from GitHub to keep environment-specific configuration private.

## 🏗️ Architecture

```text
                         AWS Cloud
                             |
             +---------------+---------------+
             |                               |
             v                               v
          VPC 1                            VPC 2
       10.0.0.0/24                       11.0.0.0/24
             |                               |
             v                               v
          Subnet 1                         Subnet 2
       10.0.0.0/28                      11.0.0.0/28
             |                               |
             v                               v
        EC2 Instance 1                  EC2 Instance 2
        Private IP:                     Private IP:
                    
             |                               |
             +---------------+---------------+
                             |
                             v
                    VPC Peering Connection
                             |
                  Private Network Communication
                             |
                   SSH / HTTP / curl Testing
```

## ☁️ AWS Resources

### 1. VPC 1

The first Virtual Private Cloud provides an isolated network environment for the first EC2 instance.

Example CIDR block: `10.0.0.0/24`

### 2. VPC 2

The second VPC provides an isolated network environment for the second EC2 instance.

Example CIDR block: `11.0.0.0/24`

### 3. Subnets

A subnet is configured inside each VPC to host an EC2 instance.

- Subnet 1 belongs to VPC 1.
- Subnet 2 belongs to VPC 2.

### 4. EC2 Instances

Two EC2 instances are deployed, with one instance in each VPC.

The instances are used to verify private communication across the VPC peering connection.

### 5. VPC Peering Connection

A VPC peering connection establishes a private network connection between VPC 1 and VPC 2.

It allows resources in the two VPCs to communicate using private IP addresses when the necessary routes and security rules are configured.

### 6. Route Tables

Route tables are configured to direct traffic between the VPC CIDR blocks through the VPC peering connection.

- The route table for VPC 1 contains a route to VPC 2 through the peering connection.
- The route table for VPC 2 contains a route to VPC 1 through the peering connection.

Both directions must be configured for bidirectional communication.

### 7. Security Groups

Security groups control the traffic allowed to and from the EC2 instances.

Rules must allow the required traffic from the other VPC's private IP range or from an appropriately scoped source.

For example, HTTP traffic on port `80` can be allowed for connectivity testing if a web server is running on the destination instance.

## 🛠️ Technologies Used

- **Amazon VPC** — Network isolation
- **Amazon EC2** — Virtual servers
- **VPC Peering** — Private connectivity between VPCs
- **Subnets** — Network segmentation
- **Route Tables** — Traffic routing between VPCs
- **Security Groups** — Instance-level traffic control
- **Terraform** — Infrastructure as Code
- **Git and GitHub** — Version control and documentation

## 📂 Project Structure

Example Terraform project structure:

```text
aws-vpc-peering/
│
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── .gitignore
└── README.md
```

The `terraform.tfvars` file is intentionally excluded from GitHub.

| File | Description |
|---|---|
| `main.tf` | Defines VPCs, subnets, EC2 instances, peering, routes, and other resources |
| `variables.tf` | Declares Terraform input variables |
| `outputs.tf` | Defines useful outputs, such as VPC IDs and instance private IPs |
| `provider.tf` | Configures the AWS provider and region |
| `.gitignore` | Prevents local and sensitive files from being committed |
| `README.md` | Documents the project |

*Your actual filenames may differ depending on your Terraform configuration.*

## ⚙️ Prerequisites

Before deploying the infrastructure, ensure you have:

1. An AWS account.
2. Terraform installed on your local machine.
3. AWS CLI installed and configured, or another supported AWS credentials method.
4. Appropriate AWS IAM permissions.
5. Valid AMI IDs for the selected AWS region.
6. An existing EC2 key pair if your instances use SSH key-based authentication.
7. Non-overlapping CIDR blocks for the two VPCs.

### Verify Terraform Installation

```bash
terraform -version
```

### Configure AWS Credentials

```bash
aws configure
```

Alternatively, use an IAM role or environment variables to provide AWS credentials.

**Security reminder:** Never hardcode AWS access keys or secrets in Terraform configuration files.

## �� Configuration and Security

The `terraform.tfvars` file contains environment-specific configuration values, including:

- AMI ID
- EC2 instance type
- EC2 key pair name
- peer_owner_id  (account id for the receiver)

This file is not uploaded to GitHub because I keep my local configuration separate from the public repository.

Anyone cloning this project must create their own local `terraform.tfvars` file before deploying the infrastructure.

### Example terraform.tfvars

Create a file named `terraform.tfvars` in the project root directory.

```hcl
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t2.micro"
key_name      = "your-key-pair-name"
peer_owner_id
```

Replace the example values with values appropriate for your AWS environment.

**Important:**
- Use a valid AMI ID for your selected AWS region.
- Choose an instance type supported by your account and region.
- Use an existing EC2 key pair name.
- The key pair name is not the private SSH key itself.
- Never upload private SSH keys, AWS credentials, or other secrets to GitHub.
- The variable names must match the declarations in `variables.tf`.

If your two EC2 instances use different AMIs, instance types, or key pairs, adjust your Terraform variables accordingly.

### Example .gitignore

Add a `.gitignore` file to help prevent accidental uploads of local Terraform files.

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

**Note:** Terraform state files can contain sensitive information. Do not commit them to GitHub.

Adding a file to `.gitignore` does not remove it from Git history if it was committed previously. If credentials or secrets were exposed, remove them from tracking and rotate the affected credentials.

## 🚀 Deployment Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/kvnikhildev/aws-vpc-peering.git
```

Navigate to the project directory:

```bash
cd aws-vpc-peering
```

Replace the repository URL and directory name if your actual repository uses a different name.

### Step 2: Create the Variables File

Create a local `terraform.tfvars` file in the project root.

Example:

```hcl
ami_id        = "ami-xxxxxxxxxxxxxxxxx"
instance_type = "t2.micro"
key_name      = "your-key-pair-name"
```

Update the values to match your AWS environment.

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

These commands format the Terraform files and validate the configuration.

### Step 5: Review the Execution Plan

```bash
terraform plan
```

Review the proposed infrastructure changes before deployment.

### Step 6: Deploy the Infrastructure

```bash
terraform apply
```

Review the execution plan and confirm when prompted.

Terraform will create the resources defined in the configuration.

### Step 7: Verify the AWS Resources

Open the AWS Management Console and verify the following:

1. **VPC:** Confirm that both VPCs are created.
2. **Subnets:** Verify that each VPC has its configured subnet.
3. **EC2 Instances:** Confirm that both instances are running.
4. **VPC Peering Connections:** Verify that the peering connection is active.
5. **Route Tables:** Confirm that each VPC has a route to the other VPC through the peering connection.
6. **Security Groups:** Verify that the required communication is permitted.

## 🔄 How VPC Peering Works

VPC peering enables private IP communication between resources in two VPCs.

The communication process is:

1. Terraform creates VPC 1 and VPC 2.
2. A subnet and an EC2 instance are created in each VPC.
3. A VPC peering connection is established between the VPCs.
4. The peering connection is accepted if required.
5. Routes are added to the route tables in both VPCs.
6. Security groups are configured to permit the required traffic.
7. An EC2 instance in VPC 1 communicates with the private IP address of the instance in VPC 2.

VPC peering does not automatically configure routes or security groups. These must be configured separately.

## 🧪 Connectivity Testing and Verification

The main objective of this project is to verify communication between two EC2 instances in different VPCs using their private IP addresses.

### Step 1: Get the Private IP Addresses

Open the EC2 console and identify the private IP address of each instance.


### Step 2: Connect both EC2 Instance using their public IP

Connect to the first EC2 instance using SSH:

```bash
ssh -i your-key.pem ec2-user@<EC2-INSTANCE-1-PUBLIC-IP>
ssh -i your-key.pem ec2-user@<EC2-INSTANCE-2-PUBLIC-IP>
```

Replace the key filename and public IP address with your own values. The username depends on the AMI.


### Step 3: Test Connectivity Using curl

From the first EC2 instance, test connectivity to the second instance:

If a web server or another HTTP service is running on the second EC2 instance, execute:

```bash
curl http://<EC2-INSTANCE-2-PRIVATE-IP>


A successful HTTP response verifies that application traffic can pass between the instances over the private network.


### Step 5: Verify the Reverse Direction

If the required routes and security rules allow bidirectional communication, connect to the second EC2 instance and test the first instance's private IP address.

```bash
curl http://<EC2-INSTANCE-1-PRIVATE-IP>
```

This test requires an HTTP service on the first instance as well.

### Expected Result

Successful communication confirms that:

- The VPC peering connection is active.
- The route tables direct traffic between the VPC CIDR blocks.
- The security groups allow the required traffic.
- The destination service is reachable through the private network.

## 🔍 Troubleshooting

If communication fails, check the following:

### 1. VPC Peering Status

Ensure the VPC peering connection is active.

### 2. Route Tables

Verify that each VPC has a route to the other VPC's CIDR block through the peering connection.

### 3. Security Groups

Ensure the destination security group permits the required traffic from the source VPC or instance.

For HTTP testing, allow the application port, usually TCP port `80`, from the appropriate source.

### 4. Network ACLs

Check that network ACLs permit the required inbound and outbound traffic, including return traffic.

### 5. Application Service

Ensure an HTTP server or application is running on the destination instance and listening on the expected port.

### 6. IP Address Ranges

Ensure the VPC CIDR blocks do not overlap.

### 7. Operating System Firewall

Check whether the operating system firewall is blocking the required traffic.

## 🧹 Destroy Infrastructure

When you no longer need the infrastructure, run:

```bash
terraform destroy
```

Review the proposed changes and confirm only if you intend to delete the resources managed by Terraform.

**Warning:** This command destroys the managed infrastructure and may interrupt services.

## 🎯 Learning Outcomes

This project demonstrates practical experience with:

- Infrastructure as Code using Terraform.
- AWS VPC creation and configuration.
- Subnet configuration.
- EC2 instance provisioning.
- VPC peering connections.
- Route table configuration.
- Security group configuration.
- Private IP communication between VPCs.
- Connectivity testing using `curl`.
- Secure management of Terraform variable files.
- GitHub version control and project documentation.


## 👨‍💻 Author

**Nikhil K. V.**

GitHub: [@kvnikhildev](https://github.com/kvnikhildev)

Profile: https://github.com/kvnikhildev/

