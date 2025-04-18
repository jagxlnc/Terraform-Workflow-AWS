# Terraform Workflow for AWS

This repository contains Terraform configurations and workflows for automating AWS infrastructure deployment.

## Overview

This project aims to provide a streamlined workflow for managing AWS infrastructure using Terraform, with a focus on:

- Infrastructure as Code (IaC) best practices
- CI/CD integration for automated deployments
- Modular and reusable Terraform configurations
- Secure handling of AWS credentials and state files

## Current Infrastructure

The repository currently includes Terraform code to create:

- A private S3 bucket named "MCP-Demo-1804" with:
  - All public access blocked
  - Server-side encryption enabled (AES256)
  - Versioning enabled

## GitHub Actions Workflow

This repository includes a GitHub Actions workflow that automates the Terraform deployment process:

- **Trigger Events**:
  - Push to main branch (affecting .tf files)
  - Pull requests to main branch (affecting .tf files)
  - Manual workflow dispatch with environment selection

- **Workflow Steps**:
  1. Checkout repository
  2. Setup Terraform
  3. Configure AWS credentials
  4. Format check
  5. Initialize Terraform
  6. Validate configuration
  7. Create execution plan
  8. Apply changes (only on push to main or manual trigger)

- **Pull Request Integration**:
  - Automatically comments on PRs with the Terraform plan output
  - Helps reviewers understand the infrastructure changes

## Getting Started

### Prerequisites

- Terraform v1.0.0+
- AWS CLI configured with appropriate credentials
- Git

### Setup

1. Clone this repository:
   ```
   git clone https://github.com/jagxlnc/Terraform-Workflow-AWS.git
   cd Terraform-Workflow-AWS
   ```

2. Initialize Terraform:
   ```
   terraform init
   ```

3. Set up GitHub repository secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
   - `TF_API_TOKEN`: (Optional) Terraform Cloud API token if using Terraform Cloud

4. (Optional) Set up GitHub repository variables:
   - `AWS_REGION`: Your preferred AWS region (defaults to us-east-1)

## Project Structure

```
.
├── README.md
├── main.tf           # Main Terraform configuration
├── variables.tf      # Variable definitions
├── outputs.tf        # Output definitions
├── .gitignore        # Git ignore file
└── .github/          # GitHub Actions workflows
    └── workflows/
        └── terraform-deploy.yml
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.