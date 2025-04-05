# Terraform GCP Infrastructure

This repository contains Terraform code for provisioning and managing the infrastructure components of a Cloud Application on Google Cloud Platform (GCP). The infrastructure is modularized for maintainability and reusability.

## Table of Contents
- [Project Overview](#terraform-gcp-infrastructure)
- [Setup Instructions](#setup-instructions)
- [Module Documentation](#module-documentation)
- [Cleanup](#cleanup)

## Setup Instructions

### Prerequisites
1. Install [Terraform](https://developer.hashicorp.com/terraform/downloads)
2. Install [Google Cloud CLI](https://cloud.google.com/sdk/docs/install)

### Initial Setup
```bash
gcloud init
# Note: Do not select any projects

gcloud auth login

# Create and set Terraform up to use our current login
PROJECT_ID=dev-${RANDOM}
gcloud projects create $PROJECT_ID --set-as-default
gcloud auth application-default login
```

### Enable Required APIs
```bash
gcloud services enable compute.googleapis.com --project=$PROJECT_ID
gcloud services enable servicenetworking.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudbuild.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudfunctions.googleapis.com --project=$PROJECT_ID
gcloud services enable pubsub.googleapis.com --project=$PROJECT_ID
gcloud services enable eventarc.googleapis.com --project=$PROJECT_ID
gcloud services enable run.googleapis.com --project=$PROJECT_ID
gcloud services enable vpcaccess.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudkms.googleapis.com --project=$PROJECT_ID
gcloud services enable dns.googleapis.com --project=$PROJECT_ID
gcloud services enable networkconnectivity.googleapis.com --project=$PROJECT_ID
gcloud services enable cloudasset.googleapis.com --project=$PROJECT_ID
gcloud services enable secretmanager.googleapis.com --project=$PROJECT_ID
```

### Initialize and Apply Terraform
```bash
terraform init
terraform plan
terraform apply
```

## Module Documentation

This project is organized into the following Terraform modules:

### 1. VPC
- Creates Virtual Private Cloud network
- Configures subnets, firewall rules, and network settings
- Located in `vpc/` directory

### 2. VM Template
- Defines base VM configurations
- Creates instance templates for compute instances
- Located in `vm-template/` directory

### 3. Load Balancer
- Sets up GCP load balancing
- Configures forwarding rules and backend services
- Located in `load-balancer/` directory

### 4. Pub/Sub
- Configures Google Cloud Pub/Sub topics and subscriptions
- Sets up message handling infrastructure
- Located in `pubsub/` directory

### 5. SQL
- Provisions Cloud SQL instances
- Configures databases and users
- Located in `sql/` directory

## Troubleshooting

### Common Issues During `terraform apply`

1. **API Not Enabled**:
   - Error: "Google API not enabled"
   - Solution: Ensure all required APIs are enabled (see Setup Instructions)

2. **Permission Errors**:
   - Error: "Permission denied" or "403 Forbidden"
   - Solution: Verify your GCP account has proper IAM roles:
     ```bash
     gcloud projects add-iam-policy-binding $PROJECT_ID \
       --member=user:YOUR_EMAIL \
       --role=roles/editor
     ```

3. **Resource Creation Timeouts**:
   - Error: "Timeout waiting for operation to complete"
