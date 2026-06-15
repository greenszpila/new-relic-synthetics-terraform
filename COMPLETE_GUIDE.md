# Complete Guide: Export New Relic Synthetics to Terraform

This guide documents the complete process to export existing New Relic Synthetic monitors from your production account, manage them as Infrastructure as Code with Terraform, and deploy them to other environments (dev, staging, etc.).

**Result:** All synthetic monitors managed in version control and deployable to any New Relic account.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 1: Fetch All Synthetics](#step-1-fetch-all-synthetics)
3. [Step 2: Import to Terraform](#step-2-import-to-terraform)
4. [Step 3: Set Up Multi-Environment](#step-3-set-up-multi-environment)
5. [Step 4: Deploy to Dev Account](#step-4-deploy-to-dev-account)
6. [Step 5: Manage as Code](#step-5-manage-as-code)
7. [Troubleshooting](#troubleshooting)
8. [Official Documentation](#official-documentation)

---

## Prerequisites

- **Python 3.x** installed
- **Terraform 1.5+** installed ([Download](https://www.terraform.io/downloads))
- **New Relic User API Key** with admin permissions ([Create API Key](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/))
- **New Relic Account ID** (found in your account dropdown)
- **Git** (optional, for version control)

**⚠️ SECURITY NOTICE:** Never commit API keys or account credentials to Git. This guide uses environment variables and secure credential storage.

---

## Step 1: Fetch All Synthetics

### 1.1 Create the Python Script

Create `get-all-synthetics-guid.py`:

**SECURITY:** This script uses environment variables to avoid hardcoding credentials.

```python
import requests
import json
import os

# Configuration - SECURITY: Never commit actual API keys!
# Set via environment variable: export NEW_RELIC_API_KEY="your-key-here"
NEW_RELIC_API_KEY = os.environ.get("NEW_RELIC_API_KEY", "YOUR_API_KEY_HERE")
ACCOUNT_ID = int(os.environ.get("NEW_RELIC_ACCOUNT_ID", "0000000"))
API_URL = "https://api.eu.newrelic.com/graphql"  # Use api.newrelic.com for US

headers = {
    "Content-Type": "application/json",
    "API-Key": NEW_RELIC_API_KEY
}

# GraphQL query for synthetic monitors
query = """
query($cursor: String) {
  actor {
    entitySearch(query: "domain = 'SYNTH' AND type = 'MONITOR'") {
      results(cursor: $cursor) {
        nextCursor
        entities {
          guid
          name
          ... on SyntheticMonitorEntityOutline {
            monitorType
          }
        }
      }
    }
  }
}
"""

def fetch_all_monitors():
    monitors = []
    cursor = None
    has_next = True

    print("Fetching Synthetic monitors from New Relic...")

    while has_next:
        variables = {"cursor": cursor}
        response = requests.post(API_URL, headers=headers, json={"query": query, "variables": variables})

        if response.status_code != 200:
            raise Exception(f"Query failed: {response.status_code}: {response.text}")

        result = response.json()

        if "errors" in result:
            raise Exception(f"GraphQL Errors: {result['errors']}")

        search_results = result["data"]["actor"]["entitySearch"]["results"]

        for entity in search_results["entities"]:
            monitor_info = {
                "guid": entity["guid"],
                "name": entity["name"],
                "type": entity.get("monitorType", "UNKNOWN")
            }
            monitors.append(monitor_info)

        cursor = search_results.get("nextCursor")
        has_next = cursor is not None

    return monitors

def get_terraform_resource_type(monitor_type):
    """Map monitor type to Terraform resource"""
    type_mapping = {
        'SIMPLE': 'newrelic_synthetics_monitor',
        'BROWSER': 'newrelic_synthetics_monitor',
        'SCRIPT_API': 'newrelic_synthetics_script_monitor',
        'SCRIPT_BROWSER': 'newrelic_synthetics_script_monitor',
        'STEP_MONITOR': 'newrelic_synthetics_step_monitor'
    }
    return type_mapping.get(monitor_type, 'newrelic_synthetics_monitor')

def generate_terraform_import_blocks(monitors):
    """Generate Terraform import blocks"""
    import_blocks = []

    for monitor in monitors:
        resource_name = monitor['name'].lower()
        resource_name = resource_name.replace(' ', '_').replace('-', '_').replace('.', '_')
        resource_name = ''.join(c for c in resource_name if c.isalnum() or c == '_')
        resource_type = get_terraform_resource_type(monitor['type'])

        import_block = f"""
import {{
  to = {resource_type}.{resource_name}
  id = "{monitor['guid']}"
}}
"""
        import_blocks.append(import_block)

    return '\n'.join(import_blocks)

if __name__ == "__main__":
    try:
        all_monitors = fetch_all_monitors()
        print(f"\nSuccessfully retrieved {len(all_monitors)} monitors.\n")
        print(json.dumps(all_monitors, indent=2))

        # Generate import blocks
        with open('imports.tf', 'w') as f:
            f.write(generate_terraform_import_blocks(all_monitors))
        print("\n✓ Created 'imports.tf' with import blocks")

    except Exception as e:
        print(f"Error: {e}")
```

### 1.2 Set Environment Variables and Run

```bash
# Set your credentials via environment variables (NEVER commit these!)
export NEW_RELIC_API_KEY="your-api-key-here"
export NEW_RELIC_ACCOUNT_ID="your-account-id"

# Run the script
python3 get-all-synthetics-guid.py
```

**Output:**
- List of all monitors (JSON)
- `imports.tf` file with import blocks

**Security Note:** The script reads credentials from environment variables, not hardcoded values.

---

## Step 2: Import to Terraform

### 2.1 Create Terraform Provider Configuration

Create `provider.tf`:

```hcl
terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 3.0"
    }
  }
}

provider "newrelic" {
  account_id = var.account_id
  # API key read from NEW_RELIC_API_KEY environment variable
  region     = var.region
}
```

### 2.2 Create Variables File

Create `variables.tf`:

```hcl
variable "account_id" {
  description = "New Relic Account ID"
  type        = number
}

variable "region" {
  description = "New Relic region (US or EU)"
  type        = string
  default     = "EU"
}
```

### 2.3 Create Production Variables

**SECURITY:** Copy from example file and customize:

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars.prod
```

Edit `terraform.tfvars.prod`:

```hcl
account_id = 1234567  # Your production account ID
region     = "EU"     # or "US"
```

**Important:** This file is gitignored to protect your account ID.

### 2.4 Set API Key and Initialize

```bash
# Set your New Relic API key
export NEW_RELIC_API_KEY="your-prod-api-key"

# Initialize Terraform
terraform init
```

### 2.5 Import Monitors with Auto-Generated Config

```bash
# Remove the empty resource file if it exists
rm -f synthetics_monitors.tf

# Import all monitors and generate configuration
terraform plan -generate-config-out=generated.tf -var-file="terraform.tfvars.prod"
```

**How this works:**
1. Terraform reads `imports.tf` (created by Python script) containing monitor GUIDs
2. Connects to New Relic API and fetches FULL details for each monitor
3. Writes complete resource configurations to `generated.tf`
4. Imports monitors into `terraform.tfstate`

**Result:** You get fully-populated Terraform configs without writing them manually!

**Important:** If you see errors about `null` values or runtime versions, clean the file:

```bash
# Run the cleanup script
python3 cleanup_terraform.py
mv generated_clean.tf generated.tf
```

### 2.6 Apply to Save State

```bash
# Apply to finalize the import
terraform apply -var-file="terraform.tfvars.prod"

# Clean up imports file (no longer needed)
mv imports.tf imports.tf.prod.backup
```

### 2.7 Security Cleanup (IMPORTANT for GitHub Upload)

If you plan to upload to GitHub, clean up sensitive data:

```bash
# Run security cleanup script
python3 cleanup_terraform.py
mv generated_clean.tf generated.tf

# Verify no secrets remain
./check-secrets.sh
```

**What this does:**
- Removes hardcoded API keys from monitor scripts
- Replaces with `$secure.NR_API_KEY` (New Relic secure credentials)
- Replaces account IDs in scripts with placeholders
- Removes null values that can cause errors

See [SECURITY.md](SECURITY.md) for complete security guidelines.

---

## Step 3: Set Up Multi-Environment

### 3.1 Update generated.tf to Use Variables

```bash
# Replace hardcoded account ID with variable
sed -i '' 's/account_id[[:space:]]*=[[:space:]]*[0-9]*/account_id                              = var.account_id/g' generated.tf
```

### 3.2 Create Dev Variables

**SECURITY:** Copy from example and customize:

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars.dev
```

Edit `terraform.tfvars.dev`:

```hcl
account_id = 9876543  # Your dev account ID
region     = "EU"     # or "US"
```

**Important:** This file is gitignored to protect your account ID.

### 3.3 Create Terraform Workspaces

```bash
# Create production workspace
terraform workspace new prod

# Create development workspace
terraform workspace new dev

# List all workspaces
terraform workspace list
```

---

## Step 4: Deploy to Dev Account

### 4.1 Switch to Dev Workspace

```bash
terraform workspace select dev
```

### 4.2 Set Dev API Key

```bash
export NEW_RELIC_API_KEY="your-dev-api-key"
```

### 4.3 Deploy All Monitors to Dev

```bash
# Preview deployment
terraform plan -var-file="terraform.tfvars.dev"

# Deploy to dev account
terraform apply -var-file="terraform.tfvars.dev"
```

**Result:** All monitors are now created in your dev account!

### 4.4 Verify Deployment

```bash
# List all monitors in Terraform state
terraform state list

# Check in New Relic UI
# Navigate to: Synthetic Monitoring → All Monitors
```

---

## Step 5: Manage as Code

### 5.1 Make Changes to Monitors

```bash
# 1. Edit the configuration
vim generated.tf

# Example: Change monitor frequency
# Find your monitor and update:
period = "EVERY_10_MINUTES"  # Change to "EVERY_15_MINUTES"
```

### 5.2 Test Changes in Dev

```bash
# Switch to dev workspace
terraform workspace select dev
export NEW_RELIC_API_KEY="your-dev-api-key"

# Preview changes
terraform plan -var-file="terraform.tfvars.dev"

# Apply to dev
terraform apply -var-file="terraform.tfvars.dev"
```

### 5.3 Deploy to Production

```bash
# Switch to prod workspace
terraform workspace select prod
export NEW_RELIC_API_KEY="your-prod-api-key"

# Preview changes
terraform plan -var-file="terraform.tfvars.prod"

# Apply to prod
terraform apply -var-file="terraform.tfvars.prod"
```

### 5.4 Version Control

**SECURITY FIRST:** Always verify no secrets before committing!

```bash
# Initialize git repository (if not done)
git init

# .gitignore is already configured to protect:
# - *.tfvars (account IDs)
# - provider.tf (account references)
# - terraform.tfstate* (resource IDs)
# - *.backup (old sensitive data)

# IMPORTANT: Run security check before committing
./check-secrets.sh

# If all checks pass, commit your code
git add *.md *.py generated.tf variables.tf *.example check-secrets.sh .gitignore example_scripts/
git commit -m "Add New Relic Synthetic monitors as code

- Export monitors from New Relic to Terraform
- Multi-environment support
- All sensitive data secured
- Comprehensive documentation"

# Push to GitHub
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
git push -u origin main
```

**See also:**
- [SECURITY.md](SECURITY.md) - Security best practices
- [GITHUB_UPLOAD_CHECKLIST.md](GITHUB_UPLOAD_CHECKLIST.md) - Pre-upload verification

---

## Troubleshooting

### Error: "Plugin did not respond" or "null values"

**Solution:** Clean the generated.tf file:

```python
# Create cleanup_terraform.py
import re

def clean_terraform_file(input_file, output_file):
    with open(input_file, 'r') as f:
        content = f.read()

    # Remove null values
    content = re.sub(r'^\s+\w+\s*=\s*null\s*$', '', content, flags=re.MULTILINE)

    # Fix empty strings in arrays
    content = re.sub(r'values\s*=\s*\[(.*?),\s*""\s*\]', r'values = [\1]', content)

    # Clean up extra newlines
    content = re.sub(r'\n{3,}', '\n\n', content)

    with open(output_file, 'w') as f:
        f.write(content)

clean_terraform_file("generated.tf", "generated_clean.tf")
```

Run: `python3 cleanup_terraform.py && mv generated_clean.tf generated.tf`

### Error: "Authentication required"

**Solution:** Verify API key is set:

```bash
echo $NEW_RELIC_API_KEY

# Test API key
curl -H "Api-Key: $NEW_RELIC_API_KEY" https://api.eu.newrelic.com/graphql \
  -d '{"query": "{ actor { user { email } } }"}'
```

### Error: "Runtime values are invalid combination"

**Solution:** Fix runtime version in generated.tf:

```bash
# Find lines with jsonencode and replace
sed -i '' 's/runtime_type_version.*=.*jsonencode.*/runtime_type_version                    = "16.10"/g' generated.tf
```

### Wrong Account Deployed

**Solution:** Check workspace and redeploy:

```bash
# Check current workspace
terraform workspace show

# Destroy from wrong account
terraform destroy -var-file="terraform.tfvars.dev"

# Switch to correct workspace
terraform workspace select dev

# Redeploy
terraform apply -var-file="terraform.tfvars.dev"
```

---

## Official Documentation

### New Relic Documentation
- **Synthetic Monitoring Overview:** https://docs.newrelic.com/docs/synthetics/
- **NerdGraph API (GraphQL):** https://docs.newrelic.com/docs/apis/nerdgraph/get-started/introduction-new-relic-nerdgraph/
- **API Keys:** https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/
- **Entity Search:** https://docs.newrelic.com/docs/apis/nerdgraph/examples/nerdgraph-entities-api-tutorial/

### Terraform Documentation
- **New Relic Provider:** https://registry.terraform.io/providers/newrelic/newrelic/latest/docs
- **Synthetics Monitor:** https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/synthetics_monitor
- **Synthetics Script Monitor:** https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/synthetics_script_monitor
- **Synthetics Step Monitor:** https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/synthetics_step_monitor
- **Terraform Import:** https://developer.hashicorp.com/terraform/cli/import
- **Terraform Workspaces:** https://developer.hashicorp.com/terraform/language/state/workspaces

### Related Resources
- **Terraform Best Practices:** https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html
- **New Relic Terraform Examples:** https://github.com/newrelic/terraform-provider-newrelic/tree/main/examples

---

## Quick Reference Commands

```bash
# Fetch monitors from New Relic
python3 get-all-synthetics-guid.py

# Initialize Terraform
terraform init

# Import to production
terraform workspace select prod
export NEW_RELIC_API_KEY="prod-key"
terraform plan -generate-config-out=generated.tf -var-file="terraform.tfvars.prod"
terraform apply -var-file="terraform.tfvars.prod"

# Deploy to dev
terraform workspace select dev
export NEW_RELIC_API_KEY="dev-key"
terraform apply -var-file="terraform.tfvars.dev"

# Make changes
vim generated.tf
terraform plan -var-file="terraform.tfvars.dev"
terraform apply -var-file="terraform.tfvars.dev"

# View state
terraform state list
terraform show
```

---

## Summary

You have successfully:

✅ Exported all synthetic monitors from New Relic using NerdGraph API
✅ Generated Terraform import blocks for all monitors
✅ Imported monitors into Terraform with auto-generated configuration
✅ Set up multi-environment management with Terraform workspaces
✅ Deployed all monitors to a dev account for testing
✅ Established Infrastructure as Code workflow for synthetic monitoring

**Next Steps:**
- Commit your Terraform code to version control
- Set up CI/CD pipelines for automated deployments
- Create environment-specific customizations (frequencies, locations)
- Add alerting policies for your synthetic monitors

---

**Need Help?**
- New Relic Support: https://support.newrelic.com
- Terraform Registry Issues: https://github.com/newrelic/terraform-provider-newrelic/issues
- New Relic Community: https://discuss.newrelic.com
