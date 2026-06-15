# New Relic Synthetics as Code

Manage New Relic Synthetic monitors using Terraform for Infrastructure as Code.

[![Security](https://img.shields.io/badge/security-secured-green.svg)](.github/SECURITY.md)
[![Terraform](https://img.shields.io/badge/terraform-1.5+-purple.svg)](https://www.terraform.io/)
[![Python](https://img.shields.io/badge/python-3.x-blue.svg)](https://www.python.org/)

---

## 🚀 What This Repository Does

- **Export** all synthetic monitors from New Relic using NerdGraph API
- **Import** monitors into Terraform with auto-generated configuration
- **Deploy** to multiple environments (prod, dev, staging)
- **Manage** monitors as version-controlled code
- **Security** All sensitive data removed, uses environment variables

---

## ⚡ Quick Start

```bash
# 1. Set credentials
export NEW_RELIC_API_KEY="your-api-key"
export NEW_RELIC_ACCOUNT_ID="your-account-id"

# 2. Create config files
cp terraform.tfvars.example terraform.tfvars.prod
vim terraform.tfvars.prod  # Add your account ID

# 3. Fetch monitors
python3 get-all-synthetics-guid.py

# 4. Import to Terraform
terraform init
terraform plan -generate-config-out=generated.tf -var-file="terraform.tfvars.prod"

# 5. Deploy
terraform apply -var-file="terraform.tfvars.prod"
```

---

## 📖 Documentation

### 🎯 Start Here
**👉 [README_START_HERE.md](README_START_HERE.md)** - Main navigation and overview

### 📚 Setup Guides
- **[QUICK_START.md](QUICK_START.md)** ⭐ Recommended for first-time setup
- **[COMPLETE_GUIDE.md](COMPLETE_GUIDE.md)** - Detailed step-by-step guide (602 lines)
- **[CHEAT_SHEET.md](CHEAT_SHEET.md)** - One-page command reference

### 🛠️ Specialized Guides
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Multi-environment strategies
- **[PROCESS_DIAGRAM.md](PROCESS_DIAGRAM.md)** - Visual architecture diagrams

### 🔒 Security
- **[SECURITY.md](SECURITY.md)** - Security best practices
- **[GITHUB_UPLOAD_CHECKLIST.md](GITHUB_UPLOAD_CHECKLIST.md)** - Pre-commit verification

---

## ✨ Features

- ✅ **18 Monitors Managed** - All monitor types supported (SIMPLE, BROWSER, SCRIPT_API, SCRIPT_BROWSER, STEP_MONITOR)
- ✅ **Multi-Environment** - Deploy to prod, dev, staging using Terraform workspaces
- ✅ **Auto-Generated Config** - Terraform 1.5+ generates complete resource configurations
- ✅ **Version Controlled** - All monitors managed in Git
- ✅ **Secure** - No API keys or credentials in code, uses environment variables
- ✅ **Automated** - Python script fetches all monitors via NerdGraph API

---

## 🔧 Requirements

- Python 3.x with `requests` library
- Terraform 1.5+ ([Download](https://www.terraform.io/downloads))
- New Relic API Key ([Create API Key](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/))
- New Relic Account ID

---

## 📊 Monitor Inventory

| Type | Count | Terraform Resource |
|------|-------|-------------------|
| SIMPLE (Ping) | 1 | `newrelic_synthetics_monitor` |
| BROWSER | 3 | `newrelic_synthetics_monitor` |
| SCRIPT_API | 6 | `newrelic_synthetics_script_monitor` |
| SCRIPT_BROWSER | 6 | `newrelic_synthetics_script_monitor` |
| STEP_MONITOR | 2 | `newrelic_synthetics_step_monitor` |
| **Total** | **18** | |

---

## 🔒 Security

**This repository is secure for public sharing:**

- ✅ All API keys removed (use environment variables)
- ✅ Account IDs protected (in gitignored `.tfvars` files)
- ✅ Monitor scripts use secure credentials (`$secure.NR_API_KEY`)
- ✅ Automated security scanner included (`check-secrets.sh`)

**Before committing:**
```bash
./check-secrets.sh
```

See [SECURITY.md](SECURITY.md) for complete guidelines.

---

## 🎯 Common Workflows

### Deploy to Development
```bash
terraform workspace select dev
export NEW_RELIC_API_KEY="your-dev-api-key"
terraform apply -var-file="terraform.tfvars.dev"
```

### Deploy to Production
```bash
terraform workspace select prod
export NEW_RELIC_API_KEY="your-prod-api-key"
terraform apply -var-file="terraform.tfvars.prod"
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

---

## 📁 Repository Structure

```
.
├── README_START_HERE.md           # Main navigation
├── QUICK_START.md                 # Recommended setup guide
├── COMPLETE_GUIDE.md              # Detailed guide
├── CHEAT_SHEET.md                 # Command reference
├── SECURITY.md                    # Security guidelines
├── get-all-synthetics-guid.py     # Fetch monitors from New Relic
├── cleanup_terraform.py           # Clean generated configs
├── check-secrets.sh               # Security scanner
├── generated.tf                   # Monitor configurations
├── variables.tf                   # Variable definitions
├── provider.tf                    # Terraform provider (create from example)
├── terraform.tfvars.example       # Template (copy and customize)
├── terraform.tfvars.prod          # Production config (gitignored)
├── terraform.tfvars.dev           # Development config (gitignored)
└── example_scripts/               # Example monitor scripts
```

---

## 🤝 Contributing

1. Read [SECURITY.md](SECURITY.md) for security guidelines
2. Run `./check-secrets.sh` before committing
3. Never commit `*.tfvars`, `provider.tf`, or `terraform.tfstate*` files
4. Use environment variables for API keys

---

## 📚 Additional Resources

### New Relic Documentation
- [Synthetic Monitoring](https://docs.newrelic.com/docs/synthetics/)
- [NerdGraph API](https://docs.newrelic.com/docs/apis/nerdgraph/)
- [API Keys](https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/)

### Terraform Documentation
- [New Relic Provider](https://registry.terraform.io/providers/newrelic/newrelic/latest/docs)
- [Terraform Import](https://developer.hashicorp.com/terraform/cli/import)
- [Terraform Workspaces](https://developer.hashicorp.com/terraform/language/state/workspaces)

---

## 📞 Support

- **Issues**: Create an issue in this repository
- **New Relic Support**: https://support.newrelic.com
- **Terraform Provider Issues**: https://github.com/newrelic/terraform-provider-newrelic/issues

---

## ✅ Success Checklist

After setup, you should be able to:

- [ ] View all monitors: `terraform state list`
- [ ] Switch environments: `terraform workspace select dev|prod`
- [ ] Deploy to dev: `terraform apply -var-file=terraform.tfvars.dev`
- [ ] Deploy to prod: `terraform apply -var-file=terraform.tfvars.prod`
- [ ] See monitors in New Relic UI for both accounts
- [ ] Run security scanner: `./check-secrets.sh`

---

**Ready to get started?** → Read [README_START_HERE.md](README_START_HERE.md)
