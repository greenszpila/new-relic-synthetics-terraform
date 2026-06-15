# New Relic Synthetics → Terraform Cheat Sheet

One-page reference for exporting New Relic Synthetic monitors to Terraform and deploying to multiple environments.

---

## 📋 Prerequisites

```bash
# Required tools
terraform --version  # 1.5+
python3 --version

# Required credentials (SECURITY: Use environment variables)
export NEW_RELIC_API_KEY="your-api-key-here"
export NEW_RELIC_ACCOUNT_ID="your-account-id"

# Verify credentials are set
echo $NEW_RELIC_API_KEY
echo $NEW_RELIC_ACCOUNT_ID
```

**⚠️ SECURITY:** Never commit API keys to version control!

---

## 🚀 Quick Start (5 Steps)

### 1. Fetch All Synthetics

```bash
python3 get-all-synthetics-guid.py
# Output: imports.tf + JSON list of monitors
```

### 2. Set Up Terraform

```bash
export NEW_RELIC_API_KEY="your-prod-api-key"
terraform init
```

### 3. Import Monitors

```bash
# Remove empty placeholder files
rm -f synthetics_monitors.tf

# Import and generate configuration
terraform plan -generate-config-out=generated.tf -var-file="terraform.tfvars.prod"

# If errors with null values, clean:
python3 cleanup_terraform.py && mv generated_clean.tf generated.tf

# SECURITY: Clean up sensitive data before committing
python3 cleanup_terraform.py
mv generated_clean.tf generated.tf
```

### 4. Apply Production

```bash
terraform apply -var-file="terraform.tfvars.prod"
mv imports.tf imports.tf.backup
```

### 5. Deploy to Dev

```bash
# Update generated.tf to use variables
sed -i '' 's/account_id[[:space:]]*=[[:space:]]*[0-9]*/account_id = var.account_id/g' generated.tf

# Create workspace
terraform workspace new dev

# Deploy
export NEW_RELIC_API_KEY="your-dev-api-key"
terraform apply -var-file="terraform.tfvars.dev"
```

---

## 📁 Required Files

### `provider.tf`
```hcl
terraform {
  required_providers {
    newrelic = { source = "newrelic/newrelic", version = "~> 3.0" }
  }
}
provider "newrelic" {
  account_id = var.account_id
  # API key read from NEW_RELIC_API_KEY environment variable
  region     = var.region
}
```

### `variables.tf`
```hcl
variable "account_id" { type = number }
variable "region" { type = string, default = "EU" }
```

### `terraform.tfvars.prod` (Create from example)
**SECURITY:** Copy from terraform.tfvars.example and customize. This file is gitignored.

```bash
cp terraform.tfvars.example terraform.tfvars.prod
```

```hcl
account_id = 1234567  # Your production account ID
region     = "EU"
```

### `terraform.tfvars.dev` (Create from example)
**SECURITY:** Copy from terraform.tfvars.example and customize. This file is gitignored.

```bash
cp terraform.tfvars.example terraform.tfvars.dev
```

```hcl
account_id = 9876543  # Your dev account ID
region     = "EU"
```

---

## 🔄 Daily Operations

### Switch Environments

```bash
# Production
terraform workspace select prod
export NEW_RELIC_API_KEY="prod-key"

# Development
terraform workspace select dev
export NEW_RELIC_API_KEY="dev-key"

# Check current
terraform workspace show
```

### Make Changes

```bash
# 1. Edit configuration
vim generated.tf

# 2. Test in dev
terraform workspace select dev
terraform plan -var-file="terraform.tfvars.dev"
terraform apply -var-file="terraform.tfvars.dev"

# 3. Deploy to prod
terraform workspace select prod
terraform apply -var-file="terraform.tfvars.prod"
```

### View State

```bash
terraform state list              # List all monitors
terraform show                    # Show all details
terraform state show <resource>   # Show specific monitor
```

---

## 🐛 Common Fixes

### Fix: Plugin Crash / Null Values
```bash
python3 cleanup_terraform.py
mv generated_clean.tf generated.tf
terraform plan -var-file="terraform.tfvars.dev"
```

### Fix: Runtime Version Error
```bash
sed -i '' 's/runtime_type_version.*=.*jsonencode.*/runtime_type_version = "16.10"/g' generated.tf
```

### Fix: Wrong Account
```bash
terraform workspace show  # Check workspace
terraform destroy -var-file="terraform.tfvars.dev"
terraform apply -var-file="terraform.tfvars.dev"
```

### Fix: Auth Error
```bash
echo $NEW_RELIC_API_KEY  # Verify key is set
curl -H "Api-Key: $NEW_RELIC_API_KEY" https://api.eu.newrelic.com/graphql \
  -d '{"query": "{ actor { user { email } } }"}'
```

---

## 📊 Monitor Types → Terraform Resources

| Monitor Type | Terraform Resource |
|--------------|-------------------|
| SIMPLE | `newrelic_synthetics_monitor` |
| BROWSER | `newrelic_synthetics_monitor` |
| SCRIPT_API | `newrelic_synthetics_script_monitor` |
| SCRIPT_BROWSER | `newrelic_synthetics_script_monitor` |
| STEP_MONITOR | `newrelic_synthetics_step_monitor` |

---

## 🔗 Quick Links

**New Relic Docs:**
- Synthetics: https://docs.newrelic.com/docs/synthetics/
- NerdGraph API: https://docs.newrelic.com/docs/apis/nerdgraph/
- API Keys: https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/

**Terraform Docs:**
- NR Provider: https://registry.terraform.io/providers/newrelic/newrelic/latest/docs
- Import: https://developer.hashicorp.com/terraform/cli/import
- Workspaces: https://developer.hashicorp.com/terraform/language/state/workspaces

---

## 🔒 Security Best Practices

### Before Committing to Git

```bash
# ALWAYS run security scanner before committing
./check-secrets.sh

# Verify no sensitive data
grep -r "NRAK-" . --exclude-dir=.git --exclude="*.md"
```

### Files to Protect

- ✅ `*.tfvars` files (gitignored - contain account IDs)
- ✅ `provider.tf` (gitignored - may reference accounts)
- ✅ `terraform.tfstate*` (gitignored - contain resource IDs)
- ✅ API keys (use environment variables only)

See **[SECURITY.md](SECURITY.md)** for complete guidelines.

---

## 💡 Pro Tips

✅ Always test changes in dev first
✅ Use workspaces for environment isolation
✅ Commit `generated.tf` and `variables.tf` to git
✅ Never commit `*.tfvars` or `terraform.tfstate` files
✅ Use environment variables for API keys
✅ Run `terraform plan` before `apply`
✅ Run `./check-secrets.sh` before every commit

---

## 🎯 End State

```
Production (workspace: prod, account: 1234567)
  └─ 18 monitors imported from existing setup

Development (workspace: dev, account: 9876543)
  └─ 18 monitors created with same configuration

All monitors managed in generated.tf
Changes deployed via: terraform apply -var-file=<env>
```
