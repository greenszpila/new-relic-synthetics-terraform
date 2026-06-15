# Quick Start Guide - New Relic Synthetics with Terraform

This is a quick reference for importing and managing New Relic Synthetic monitors with Terraform.

## Prerequisites Checklist

- [ ] Python 3.x installed
- [ ] Terraform 1.5+ installed
- [ ] New Relic API Key (User API Key with admin permissions)
- [ ] New Relic Account ID

**⚠️ SECURITY:** Never commit API keys or account IDs to version control!

## 5-Minute Setup

### Step 1: Configure Authentication

**SECURITY:** Always use environment variables for credentials:

**Environment Variables (Required)**
```bash
export NEW_RELIC_API_KEY="your-api-key-here"
export NEW_RELIC_ACCOUNT_ID="your-account-id"
export NEW_RELIC_REGION="EU"  # or "US"

# Verify credentials are set
echo $NEW_RELIC_API_KEY | head -c 20  # Should show: NRAK-...
echo $NEW_RELIC_ACCOUNT_ID
```

**Configuration Files (Create from examples)**
```bash
# Create terraform.tfvars files from example
cp terraform.tfvars.example terraform.tfvars.prod
cp terraform.tfvars.example terraform.tfvars.dev

# Edit with your account IDs (files are gitignored)
vim terraform.tfvars.prod
vim terraform.tfvars.dev
```

### Step 2: Fetch Monitors and Generate Config

**SECURITY:** Ensure environment variables are set first!

```bash
# Verify credentials
echo $NEW_RELIC_API_KEY | head -c 20
echo $NEW_RELIC_ACCOUNT_ID

# Fetch monitors
python3 get-all-synthetics-guid.py
```

This creates:
- `imports.tf` - Import blocks for all monitors
- JSON output with monitor details

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Import Monitors

```bash
terraform plan -generate-config-out=generated.tf -var-file="terraform.tfvars.prod"
```

This will import all monitors and generate complete configurations.

**If you get errors with null values:**
```bash
python3 cleanup_terraform.py
mv generated_clean.tf generated.tf
```

### Step 5: Verify

```bash
terraform plan
# Should show: "No changes. Your infrastructure matches the configuration."
```

### Step 6: Apply (if needed)

```bash
terraform apply
```

## Daily Operations

### View All Monitors

```bash
terraform state list | grep newrelic_synthetics_monitor
```

### Inspect a Specific Monitor

```bash
terraform state show newrelic_synthetics_monitor.again_dummy
```

### Add a New Monitor

1. Create resource in a `.tf` file:

```hcl
resource "newrelic_synthetics_monitor" "new_api_check" {
  name             = "New API Health Check"
  type             = "SCRIPT_API"
  frequency        = 10
  status           = "ENABLED"
  locations_public = ["AWS_EU_WEST_1"]

  runtime_type         = "NODE_API"
  runtime_type_version = "16.10"
  script_language      = "JAVASCRIPT"
  script_content       = file("${path.module}/example_scripts/api_health_check.js")
}
```

2. Apply:

```bash
terraform apply
```

### Modify a Monitor

1. Edit the resource in your `.tf` file
2. Preview changes:

```bash
terraform plan
```

3. Apply changes:

```bash
terraform apply
```

### Delete a Monitor

1. Remove the resource block from your `.tf` file
2. Apply:

```bash
terraform apply
```

Terraform will ask for confirmation before deleting.

### Disable a Monitor (Don't Delete)

Change the status:

```hcl
resource "newrelic_synthetics_monitor" "my_monitor" {
  # ... other config ...
  status = "DISABLED"
}
```

Then apply:

```bash
terraform apply
```

## Common Monitor Types

### Simple Ping Monitor

```hcl
resource "newrelic_synthetics_monitor" "ping_check" {
  name             = "Example.com Ping"
  type             = "SIMPLE"
  frequency        = 5
  status           = "ENABLED"
  locations_public = ["AWS_EU_WEST_1"]
  uri              = "https://example.com"
  validation_string = "Example Domain"
  verify_ssl       = true
}
```

### API Monitor (Scripted)

```hcl
resource "newrelic_synthetics_monitor" "api_check" {
  name                 = "API Health Check"
  type                 = "SCRIPT_API"
  frequency            = 10
  status               = "ENABLED"
  locations_public     = ["AWS_EU_WEST_1", "AWS_EU_CENTRAL_1"]
  runtime_type         = "NODE_API"
  runtime_type_version = "16.10"
  script_language      = "JAVASCRIPT"
  script_content       = file("${path.module}/example_scripts/api_health_check.js")

  tag {
    key    = "Environment"
    values = ["Production"]
  }
}
```

### Browser Monitor (Scripted)

```hcl
resource "newrelic_synthetics_monitor" "browser_test" {
  name                             = "Login Flow Test"
  type                             = "SCRIPT_BROWSER"
  frequency                        = 15
  status                           = "ENABLED"
  locations_public                 = ["AWS_EU_WEST_1"]
  runtime_type                     = "CHROME_BROWSER"
  runtime_type_version             = "100"
  script_language                  = "JAVASCRIPT"
  enable_screenshot_on_failure_and_script = true
  script_content                   = file("${path.module}/example_scripts/login_flow_test.js")
}
```

## Secure Credentials

**SECURITY:** Monitor scripts should use New Relic Secure Credentials, not hardcoded values.

### Add Secure Credentials via Terraform

```hcl
resource "newrelic_synthetics_secure_credential" "api_token" {
  account_id  = var.account_id  # Use variable, not hardcoded
  key         = "NR_API_KEY"
  value       = var.secure_api_token  # From tfvars or env var
  description = "API authentication token for monitors"
}
```

### Use in Monitor Scripts

```javascript
// Use secure credentials in monitor scripts
const apiKey = $secure.NR_API_KEY;
const accountId = 'YOUR_ACCOUNT_ID';  // Placeholder, not real value
```

**Note:** All monitor scripts in this repository use `$secure.NR_API_KEY` instead of hardcoded keys.

## Monitoring Locations

Common EU locations:
- `AWS_EU_WEST_1` - Dublin, Ireland
- `AWS_EU_CENTRAL_1` - Frankfurt, Germany
- `AWS_EU_WEST_2` - London, England
- `AWS_EU_WEST_3` - Paris, France

Common US locations:
- `AWS_US_EAST_1` - Washington DC
- `AWS_US_WEST_1` - San Francisco
- `AWS_US_WEST_2` - Portland

See `variables.tf.example` for complete list.

## Frequency Options

- `1` - Every minute
- `5` - Every 5 minutes
- `10` - Every 10 minutes
- `15` - Every 15 minutes
- `30` - Every 30 minutes
- `60` - Every hour
- `360` - Every 6 hours
- `720` - Every 12 hours
- `1440` - Every 24 hours

## Security Best Practices

**Before committing to git:**

```bash
# ALWAYS run security scanner
./check-secrets.sh

# Verify no hardcoded credentials
grep -r "NRAK-" . --exclude-dir=.git --exclude="*.md"
```

**Protected files (.gitignored):**
- `*.tfvars` (except .example)
- `provider.tf`
- `terraform.tfstate*`
- `*.backup`

See **[SECURITY.md](SECURITY.md)** and **[GITHUB_UPLOAD_CHECKLIST.md](GITHUB_UPLOAD_CHECKLIST.md)** for complete guidelines.

## Troubleshooting

### Import Failed

```bash
# Re-fetch monitor list
python3 get-all-synthetics-guid.py

# Check imports.tf was created
ls -la imports.tf
```

### Authentication Failed

```bash
# Verify API key is set
echo $NEW_RELIC_API_KEY | head -c 20
# Should show: NRAK-...

# Test API key
curl -H "Api-Key: $NEW_RELIC_API_KEY" https://api.eu.newrelic.com/graphql \
  -d '{"query": "{ actor { user { email } } }"}'
```

### Configuration Drift

If changes were made in the UI:

```bash
# See what changed
terraform plan

# Update Terraform to match current state
terraform refresh
```

### Re-import After Manual Changes

```bash
# Fetch latest monitor list
python3 get-all-synthetics-guid.py

# Remove old state
terraform state rm newrelic_synthetics_monitor.monitor_name

# Re-import
terraform plan -generate-config-out=updated.tf
```

## Useful Commands

```bash
# Format all .tf files
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# List all resources
terraform state list

# Refresh state from New Relic
terraform refresh

# Plan with detailed output
terraform plan -out=tfplan

# Apply saved plan
terraform apply tfplan

# Destroy specific resource
terraform destroy -target=newrelic_synthetics_monitor.test_monitor
```

## File Structure

```
.
├── get-all-synthetics-guid.py    # Python script to fetch monitors
├── provider.tf                   # Terraform provider config (create from example)
├── imports.tf                    # Generated import blocks
├── synthetics_monitors.tf        # Monitor resources (or use generated.tf)
├── variables.tf                  # Variable definitions (optional)
├── terraform.tfvars              # Variable values (optional, don't commit)
├── example_scripts/              # Example monitor scripts
│   ├── api_health_check.js
│   ├── api_post_with_auth.js
│   └── login_flow_test.js
└── README.md                     # Full documentation
```

## Next Steps

1. Review `README.md` for detailed documentation
2. Check `example_scripts/` for monitor script templates
3. Copy `variables.tf.example` to `variables.tf` for reusable configuration
4. Set up alert conditions for your monitors
5. Consider organizing monitors by environment or team

## Resources

- [New Relic Terraform Provider](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs)
- [Synthetic Monitoring Docs](https://docs.newrelic.com/docs/synthetics/)
- [NerdGraph API](https://docs.newrelic.com/docs/apis/nerdgraph/)

## Support

- Script issues: Check Python output and API permissions
- Terraform issues: Run `terraform validate` and check provider version
- New Relic API: Check account permissions and region settings
