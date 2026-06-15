# Multi-Environment Deployment Guide

This guide shows how to deploy your synthetic monitors to multiple New Relic accounts (prod, dev, staging, etc.).

## Configuration Files

- **`variables.tf`** - Variable definitions
- **`provider.tf`** - Provider configuration (now uses variables)
- **`generated.tf`** - Monitor configurations (now uses `var.account_id`)
- **`terraform.tfvars.prod`** - Production account settings
- **`terraform.tfvars.dev`** - Development account settings

## Setup

### 1. Configure Your Dev Account

**SECURITY:** Create from example file and customize:

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars.dev
```

Edit `terraform.tfvars.dev` and add your dev account details:

```hcl
account_id = 1234567  # Your DEV account ID
region     = "EU"     # or "US"
```

**Important:** This file is gitignored to protect your account ID.

### 2. Set Environment-Specific API Keys

**⚠️ SECURITY:** API keys must be stored in environment variables, NEVER in code.

**For Production:**
```bash
export NEW_RELIC_API_KEY="your-prod-api-key"
```

**For Development:**
```bash
export NEW_RELIC_API_KEY="your-dev-api-key"
```

**Verify the key is set:**
```bash
echo $NEW_RELIC_API_KEY | head -c 20
# Should show: NRAK-...
```

## Deployment Methods

### Method 1: Using Variable Files (Recommended)

Deploy to each environment by specifying the var file:

#### Deploy to Production
```bash
# Set prod API key
export NEW_RELIC_API_KEY="your-prod-api-key"

# Apply with prod vars
terraform apply -var-file="terraform.tfvars.prod"
```

#### Deploy to Development
```bash
# Set dev API key
export NEW_RELIC_API_KEY="your-dev-api-key"

# Apply with dev vars
terraform apply -var-file="terraform.tfvars.dev"
```

**Note:** This method uses the same state file, so deploying to dev will overwrite prod resources. Use Terraform workspaces (Method 2) to manage both simultaneously.

---

### Method 2: Using Terraform Workspaces (Manage Multiple Environments)

Workspaces allow you to maintain separate state files for each environment.

#### Initial Setup

1. **Create workspaces:**
```bash
# You're currently in the 'default' workspace
terraform workspace new prod
terraform workspace new dev
```

2. **List workspaces:**
```bash
terraform workspace list
```

#### Deploy to Production

```bash
# Switch to prod workspace
terraform workspace select prod

# Set prod API key
export NEW_RELIC_API_KEY="your-prod-api-key"

# Apply with prod variables
terraform apply -var-file="terraform.tfvars.prod"
```

#### Deploy to Development

```bash
# Switch to dev workspace
terraform workspace select dev

# Set dev API key
export NEW_RELIC_API_KEY="your-dev-api-key"

# Apply with dev variables
terraform apply -var-file="terraform.tfvars.dev"
```

#### Switch Between Environments

```bash
# Check current workspace
terraform workspace show

# Switch to prod
terraform workspace select prod
terraform plan -var-file="terraform.tfvars.prod"

# Switch to dev
terraform workspace select dev
terraform plan -var-file="terraform.tfvars.dev"
```

---

### Method 3: Separate Directories (Full Isolation)

Create completely separate directories for each environment:

```bash
# Create environment directories
mkdir -p environments/prod
mkdir -p environments/dev

# Copy files to each environment
cp generated.tf variables.tf provider.tf environments/prod/
cp generated.tf variables.tf provider.tf environments/dev/

# Create environment-specific tfvars
cp terraform.tfvars.prod environments/prod/terraform.tfvars
cp terraform.tfvars.dev environments/dev/terraform.tfvars
```

#### Deploy to Production
```bash
cd environments/prod
export NEW_RELIC_API_KEY="your-prod-api-key"
terraform init
terraform apply
```

#### Deploy to Development
```bash
cd environments/dev
export NEW_RELIC_API_KEY="your-dev-api-key"
terraform init
terraform apply
```

---

## Quick Reference Commands

### Check Which Environment You're In
```bash
# If using workspaces
terraform workspace show

# If using separate directories
pwd
```

### View Current Configuration
```bash
# Show what would be deployed
terraform plan -var-file="terraform.tfvars.dev"

# List all monitors in state
terraform state list

# Show specific monitor details
terraform state show newrelic_synthetics_monitor.test_emanuele
```

### Update a Specific Monitor
```bash
# Edit generated.tf
# Then apply only that resource
terraform apply -target=newrelic_synthetics_monitor.test_emanuele -var-file="terraform.tfvars.dev"
```

### Destroy Monitors in an Environment
```bash
# ⚠️ WARNING: This deletes all monitors
terraform destroy -var-file="terraform.tfvars.dev"

# Destroy a specific monitor
terraform destroy -target=newrelic_synthetics_monitor.test -var-file="terraform.tfvars.dev"
```

---

## Environment-Specific Customization

You can customize monitors per environment by using conditional logic:

### Option 1: Create Environment-Specific Files

```bash
# generated.tf -> Base monitors
# monitors_dev_only.tf -> Dev-specific monitors
# monitors_prod_only.tf -> Prod-specific monitors
```

### Option 2: Use Terraform Locals

Add to your configuration:

```hcl
locals {
  environment = terraform.workspace

  # Different frequencies per environment
  monitor_frequency = local.environment == "prod" ? "EVERY_5_MINUTES" : "EVERY_HOUR"

  # Different locations per environment
  monitor_locations = local.environment == "prod" ? [
    "EU_WEST_1",
    "EU_CENTRAL_1",
    "EU_WEST_2"
  ] : [
    "EU_WEST_1"
  ]
}
```

Then use in your monitors:
```hcl
resource "newrelic_synthetics_monitor" "example" {
  period           = local.monitor_frequency
  locations_public = local.monitor_locations
  # ... other config
}
```

---

## Security Best Practices

**⚠️ CRITICAL:** This repository has been secured for public sharing. Follow these practices to maintain security.

### 1. Never Commit Sensitive Files

**.gitignore** is already configured to exclude:
```bash
# These files are automatically protected
*.tfvars                    # Account IDs
!terraform.tfvars.example   # Example file is safe
provider.tf                 # May contain account references
terraform.tfstate*          # Resource IDs and metadata
*.backup                    # May contain old sensitive data
```

### 2. Use Environment Variables for API Keys

**NEVER hardcode API keys in any file!**

```bash
# Add to ~/.bashrc or ~/.zshrc
export NEW_RELIC_PROD_API_KEY="your-prod-key"
export NEW_RELIC_DEV_API_KEY="your-dev-key"

# Switch between them as needed
export NEW_RELIC_API_KEY=$NEW_RELIC_PROD_API_KEY
export NEW_RELIC_API_KEY=$NEW_RELIC_DEV_API_KEY
```

### 3. Run Security Scanner Before Commits

```bash
# ALWAYS run before committing
./check-secrets.sh

# Verify no secrets found
grep -r "NRAK-" . --exclude-dir=.git --exclude="*.md"
```

See **[SECURITY.md](SECURITY.md)** and **[GITHUB_UPLOAD_CHECKLIST.md](GITHUB_UPLOAD_CHECKLIST.md)** for complete guidelines.

### 3. Use Helper Scripts

Create `deploy-prod.sh`:
```bash
#!/bin/bash
export NEW_RELIC_API_KEY=$NEW_RELIC_PROD_API_KEY
terraform workspace select prod
terraform apply -var-file="terraform.tfvars.prod"
```

Create `deploy-dev.sh`:
```bash
#!/bin/bash
export NEW_RELIC_API_KEY=$NEW_RELIC_DEV_API_KEY
terraform workspace select dev
terraform apply -var-file="terraform.tfvars.dev"
```

Make them executable:
```bash
chmod +x deploy-prod.sh deploy-dev.sh
```

---

## Common Workflows

### Initial Deployment to Dev
```bash
# 1. Create dev workspace
terraform workspace new dev

# 2. Set dev API key
export NEW_RELIC_API_KEY="your-dev-api-key"

# 3. Plan deployment
terraform plan -var-file="terraform.tfvars.dev"

# 4. Apply if everything looks good
terraform apply -var-file="terraform.tfvars.dev"
```

### Sync Changes from Prod to Dev
```bash
# 1. Make changes in generated.tf

# 2. Apply to dev first for testing
terraform workspace select dev
export NEW_RELIC_API_KEY="your-dev-api-key"
terraform apply -var-file="terraform.tfvars.dev"

# 3. After testing, apply to prod
terraform workspace select prod
export NEW_RELIC_API_KEY="your-prod-api-key"
terraform apply -var-file="terraform.tfvars.prod"
```

### Rollback Changes
```bash
# View state history
terraform state pull

# Restore from backup
cp terraform.tfstate.backup terraform.tfstate
terraform apply -var-file="terraform.tfvars.dev"
```

---

## Troubleshooting

### Wrong Account Deployed
```bash
# Check which account is configured
terraform console
> var.account_id

# Verify workspace
terraform workspace show

# Destroy and redeploy
terraform destroy -var-file="terraform.tfvars.dev"
terraform apply -var-file="terraform.tfvars.dev"
```

### API Key Issues
```bash
# Verify API key is set
echo $NEW_RELIC_API_KEY

# Test API key
curl -H "Api-Key: $NEW_RELIC_API_KEY" https://api.eu.newrelic.com/graphql \
  -d '{"query": "{ actor { user { email } } }"}'
```

### State Lock Issues
```bash
# If state is locked
terraform force-unlock <lock-id>

# Use local state instead of remote (if applicable)
terraform state pull > terraform.tfstate.backup
```

---

## Summary

**Recommended Approach:** Use **Method 2 (Workspaces)** for most use cases.

**Pros:**
- ✅ Manage multiple environments from one directory
- ✅ Separate state files per environment
- ✅ Easy to switch between environments
- ✅ Consistent configuration across environments

**Quick Commands:**
```bash
# Deploy to dev
terraform workspace select dev
export NEW_RELIC_API_KEY="dev-key"
terraform apply -var-file="terraform.tfvars.dev"

# Deploy to prod
terraform workspace select prod
export NEW_RELIC_API_KEY="prod-key"
terraform apply -var-file="terraform.tfvars.prod"
```
