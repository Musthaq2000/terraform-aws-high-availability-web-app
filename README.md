# Terraform AWS High Availability Web Application

This project provisions a highly available web application on AWS using **Terraform**.

The infrastructure includes a custom VPC, public subnets across multiple Availability Zones, EC2 instances, an Application Load Balancer, IAM roles, and Amazon S3 for website deployment.

The web application is automatically downloaded from Amazon S3 during EC2 provisioning using User Data.

---

# Architecture

```
                    Internet
                        │
                        ▼
             Application Load Balancer
                        │
          ┌─────────────┴─────────────┐
          │                           │
          ▼                           ▼
      EC2 Instance 1             EC2 Instance 2
          │                           │
          └─────────────┬─────────────┘
                        │
                        ▼
                  Amazon S3 Bucket
                (Website Files)
```

---

# Services Used

- Terraform
- AWS VPC
- Public Subnets
- Internet Gateway
- Route Tables
- Security Groups
- EC2
- Application Load Balancer
- Target Groups
- IAM Role
- IAM Instance Profile
- Amazon S3
- User Data

---

# Features

- Infrastructure as Code (Terraform)
- High Availability across two Availability Zones
- Automatic Load Balancing
- Automated website deployment from S3
- IAM Role based authentication
- No AWS credentials stored on EC2
- User Data bootstrapping
- Dynamic health checks using ALB

---

# Folder Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── iam.tf
├── userdata1.sh
├── userdata2.sh
├── server1/
│   ├── index.html
│   └── style.css
├── server2/
│   ├── index.html
│   └── style.css
└── README.md
```

---

# Deployment Flow

1. Terraform provisions the networking components.
2. Two EC2 instances are launched.
3. IAM Instance Profile is attached to each EC2 instance.
4. User Data installs Apache and AWS CLI.
5. Website files are downloaded from Amazon S3.
6. Apache serves the website.
7. Application Load Balancer distributes traffic across both EC2 instances.

---

# Prerequisites

- AWS Account
- Terraform
- AWS CLI
- SSH Key Pair
- Amazon S3 Bucket
- IAM Role with AmazonS3ReadOnlyAccess

---

# Deployment

Initialize Terraform

```bash
terraform init
```

Validate

```bash
terraform validate
```

Review the execution plan

```bash
terraform plan
```

Deploy

```bash
terraform apply
```

Destroy

```bash
terraform destroy
```

---

# Verification

Open the Application Load Balancer DNS name.

Refresh the page multiple times.

Traffic should alternate between:

- Server 1
- Server 2

This confirms that the Application Load Balancer is distributing traffic successfully.

---

# Learning Outcomes

Through this project I learned:

- Designing AWS networking using Terraform
- Building reusable Infrastructure as Code
- Configuring Application Load Balancers
- Working with Target Groups
- Bootstrapping EC2 using User Data
- Managing permissions with IAM Roles
- Deploying static website assets from Amazon S3
- Troubleshooting EC2 bootstrapping using Cloud-Init logs

---

# Future Improvements

- HTTPS using AWS Certificate Manager
- Route53 custom domain
- Auto Scaling Group
- Launch Template
- CloudWatch Monitoring
- Terraform Modules
- Remote State using S3 + DynamoDB
- CI/CD with GitHub Actions
