# Terraform EC2 Project

**By:** Waqas Saleem — DevOps Engineer, Miseacademy
**Region:** us-east-1
**Tool:** Terraform (AWS Academy Learner Lab)

---

## Overview

Ye project Terraform use karke ek AWS EC2 instance provision karta hai — SSH key pair, security group, aur default VPC ki subnet automatically detect karke. Purane console-based VPC project ko IaC (Infrastructure as Code) me convert karne ka pehla step.

---

## What this creates

| Resource | Purpose |
|---|---|
| `aws_key_pair` | SSH key pair (`terrafrom1`) — local `id_rsa.pub` se |
| `aws_security_group` | SSH (port 22) allow karta hai inbound, sab outbound allow |
| `data "aws_vpc"` | Default VPC dhoondta hai automatically |
| `data "aws_subnets"` | Default VPC ki available subnets list karta hai |
| `aws_instance` | Ek `t2.micro` EC2 instance, Amazon Linux 2 AMI |

---

## Prerequisites

- Terraform installed (`terraform -version` se confirm)
- AWS CLI installed aur configured
- SSH public key maujood ho: `~/.ssh/id_rsa.pub` (nahi hai to `ssh-keygen -t rsa -b 4096` se banao)

### AWS Academy Learner Lab credentials
Ye AWS Academy student account hai — normal Access Key + Secret Key kaafi nahi hoti, **Session Token bhi zaroori hai**:

```bash
aws configure          # Access Key + Secret Key + region (us-east-1) + json
aws configure set aws_session_token "YOUR_SESSION_TOKEN"
```

Session token AWS Academy dashboard ke **"AWS Details"** button se milta hai. Yaad rahe — ye token lab session refresh hone pe **expire** ho jata hai, expire hote hi dobara set karna padega.

Verify:
```bash
aws sts get-caller-identity
```

---

## Usage

```bash
terraform init
terraform plan
terraform apply
```

`apply` confirm karne ke liye `yes` type karo.

Apply hone ke baad output me instance ka public IP, DNS, aur ready SSH command milega:
```bash
terraform output
```

Destroy karne ke liye:
```bash
terraform destroy
```

---

## Issues faced & fixes

**1. `InvalidClientTokenId` error**
Wajah: AWS Academy temporary credentials (`ASIA...`) ke sath session token missing tha.
Fix: `aws configure set aws_session_token "..."` se token add kiya.

**2. `No subnets found for the default VPC`**
Wajah: Default VPC me hardcoded subnet nahi thi.
Fix: `data "aws_vpc"` aur `data "aws_subnets"` se dynamically default VPC/subnet detect karwaya.

**3. GitHub push reject — large files**
Wajah: `.terraform/` provider binary (845MB) aur `awscliv2.zip` (69MB) galti se commit ho gaye the — GitHub ki 100MB limit se bade.
Fix: `.gitignore` add ki (`.terraform/`, `*.tfstate`, `*.zip`), aur history clean karke fresh push kiya.

---

## .gitignore

```
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl
awscliv2.zip
*.zip
```

---

## Next Steps
- Terraform state ko remote backend (S3 + DynamoDB lock) me move karna
- VPC bhi Terraform se banana (abhi default VPC use ho raha hai)
- Variables file (`variables.tf`) alag banana hardcoded values ke liye
