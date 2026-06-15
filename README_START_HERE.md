# New Relic Synthetics as Code - Start Here 📚

Welcome! This repository contains everything you need to manage New Relic Synthetic monitors as Infrastructure as Code using Terraform.

---

## 🎯 What We Accomplished

✅ **Exported** 18 synthetic monitors from New Relic production account
✅ **Imported** all monitors into Terraform with full configuration
✅ **Set up** multi-environment management (prod + dev workspaces)
✅ **Deployed** all monitors to dev account for testing
✅ **Established** Infrastructure as Code workflow for synthetic monitoring

---

## 📖 Documentation

**Choose ONE guide based on your needs:**

### ⭐ **RECOMMENDED: Quick Start** (Most People)
**Read:** [`QUICK_START.md`](./QUICK_START.md)
**Best for:** First-time setup with good balance of detail and speed
**Contains:** Essential steps, security best practices, common monitor types, troubleshooting

### 📚 **Complete Guide** (Maximum Detail)
**Read:** [`COMPLETE_GUIDE.md`](./COMPLETE_GUIDE.md)
**Best for:** Those who want every detail explained, comprehensive troubleshooting
**Contains:** 602 lines of step-by-step instructions with full explanations

### ⚡ **Cheat Sheet** (Daily Reference)
**Read:** [`CHEAT_SHEET.md`](./CHEAT_SHEET.md)
**Best for:** Quick command lookup when you already know the process
**Contains:** One-page reference with common commands and fixes

---

### 📖 Additional Specialized Guides

### 🛠️ **Deployment Guide** (Multi-Environment)
**Read:** [`DEPLOYMENT_GUIDE.md`](./DEPLOYMENT_GUIDE.md)
**Best for:** Understanding different deployment strategies (workspaces, separate dirs, etc.)
**Contains:** Detailed deployment strategies and environment management

### 🔄 **Process Diagram**
**Read:** [`PROCESS_DIAGRAM.md`](./PROCESS_DIAGRAM.md)
**Best for:** Visual learners who want to understand data flow
**Contains:** Visual diagrams and architecture explanations

---

## 🎯 Quick Decision Guide

**Never done this before?** → Start with **QUICK_START.md**

**Want maximum detail?** → Use **COMPLETE_GUIDE.md**

**Already set up, need commands?** → Use **CHEAT_SHEET.md**

**Multiple environments?** → Use **DEPLOYMENT_GUIDE.md**

---

## ⚡ Quick Start (2 Minutes)

If you already have this setup and just want to deploy:

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

### Check Current Environment
```bash
terraform workspace show
terraform state list
```

---

## 📁 Important Files

### Configuration Files (Edit These)
- **`generated.tf`** - Monitor configurations (432 lines, 18 monitors)
- **`terraform.tfvars.prod`** - Production account settings
- **`terraform.tfvars.dev`** - Development account settings

### Infrastructure Files (Don't Edit)
- **`provider.tf`** - Terraform provider configuration
- **`variables.tf`** - Variable definitions

### Utility Scripts
- **`get-all-synthetics-guid.py`** - Fetch monitors from New Relic
- **`cleanup_terraform.py`** - Clean generated Terraform configs
- **`deploy.sh`** - Deployment helper script

---

## 🔑 Environment Setup

### Required Environment Variables

**SECURITY:** Never commit API keys to Git! Always use environment variables.

```bash
export NEW_RELIC_API_KEY="your-api-key-here"
export NEW_RELIC_ACCOUNT_ID="your-account-id"
```

### Configuration Files Setup

1. **Copy example files:**
```bash
cp terraform.tfvars.example terraform.tfvars.prod
cp terraform.tfvars.example terraform.tfvars.dev
```

2. **Edit with your account IDs:**
```bash
# terraform.tfvars.prod
account_id = 1234567  # Your production account ID
region     = "EU"

# terraform.tfvars.dev
account_id = 9876543  # Your development account ID
region     = "EU"
```

**Note:** `.tfvars` files are gitignored to protect your account IDs.

---

## 📊 Monitor Inventory

**Total Monitors:** 18

| Type | Count | Terraform Resource |
|------|-------|-------------------|
| SIMPLE (Ping) | 1 | `newrelic_synthetics_monitor` |
| BROWSER | 3 | `newrelic_synthetics_monitor` |
| SCRIPT_API | 6 | `newrelic_synthetics_script_monitor` |
| SCRIPT_BROWSER | 6 | `newrelic_synthetics_script_monitor` |
| STEP_MONITOR | 2 | `newrelic_synthetics_step_monitor` |

---

## 🔄 Common Workflows

### Make a Change to a Monitor

```bash
# 1. Edit the configuration
vim generated.tf

# 2. Test in dev
terraform workspace select dev
export NEW_RELIC_API_KEY="dev-key"
terraform plan -var-file="terraform.tfvars.dev"
terraform apply -var-file="terraform.tfvars.dev"

# 3. Verify in New Relic UI
# Navigate to: Synthetic Monitoring → [Your Monitor]

# 4. Deploy to prod
terraform workspace select prod
export NEW_RELIC_API_KEY="prod-key"
terraform apply -var-file="terraform.tfvars.prod"
```

### Add a New Monitor

```bash
# 1. Add resource block to generated.tf
cat >> generated.tf << 'EOF'

resource "newrelic_synthetics_monitor" "my_new_monitor" {
  account_id       = var.account_id
  name             = "My New Monitor"
  type             = "SIMPLE"
  period           = "EVERY_5_MINUTES"
  status           = "ENABLED"
  locations_public = ["EU_WEST_1"]
  uri              = "https://example.com"
  verify_ssl       = true
}
EOF

# 2. Deploy
terraform apply -var-file="terraform.tfvars.dev"
```

### View Monitor Details

```bash
# List all monitors
terraform state list

# Show specific monitor
terraform state show newrelic_synthetics_monitor.test_emanuele

# Show all resources
terraform show
```

---

## 🐛 Troubleshooting

### Quick Fixes

| Problem | Solution |
|---------|----------|
| Auth error | `echo $NEW_RELIC_API_KEY` to verify key is set |
| Wrong account | `terraform workspace show` to check workspace |
| Plugin crash | Run `python3 cleanup_terraform.py` |
| Runtime error | Check `COMPLETE_GUIDE.md` troubleshooting section |

### Get Help
- Check the [Troubleshooting](./COMPLETE_GUIDE.md#troubleshooting) section in the complete guide
- Review [common fixes](./CHEAT_SHEET.md#-common-fixes) in the cheat sheet
- New Relic Support: https://support.newrelic.com

---

## 🔗 Official Resources

### New Relic
- **Synthetic Monitoring:** https://docs.newrelic.com/docs/synthetics/
- **NerdGraph API:** https://docs.newrelic.com/docs/apis/nerdgraph/
- **API Keys:** https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/

### Terraform
- **New Relic Provider:** https://registry.terraform.io/providers/newrelic/newrelic/latest/docs
- **Synthetics Monitor Resource:** https://registry.terraform.io/providers/newrelic/newrelic/latest/docs/resources/synthetics_monitor
- **Terraform Import:** https://developer.hashicorp.com/terraform/cli/import
- **Workspaces:** https://developer.hashicorp.com/terraform/language/state/workspaces

---

## 🎯 Next Steps

1. **Review the documentation** that matches your needs (see above)
2. **Test making a change** to a monitor in dev
3. **Set up version control** (if not already done)
4. **Create a CI/CD pipeline** for automated deployments
5. **Add more environments** (staging, QA, etc.)

---

## 🔒 Security

**IMPORTANT:** This repository has been secured for public sharing.

- ✅ All API keys removed (use environment variables)
- ✅ Account IDs protected (in gitignored `.tfvars` files)
- ✅ Monitor scripts use secure credentials (`$secure.NR_API_KEY`)
- ✅ Automated security scanner included (`check-secrets.sh`)

### Before Committing

Always run the security scanner:
```bash
./check-secrets.sh
```

See **[SECURITY.md](SECURITY.md)** for complete security guidelines.

---

## 📝 Version Control Setup

If you haven't already, initialize git:

```bash
# Initialize repository
git init

# .gitignore is already configured to exclude:
# - *.tfvars (contains account IDs)
# - provider.tf (contains account references)
# - terraform.tfstate* (contains resource IDs)
# - *.backup (may contain sensitive data)

# Run security check
./check-secrets.sh

# Make initial commit
git add *.md *.py generated.tf variables.tf *.example check-secrets.sh .gitignore example_scripts/
git commit -m "Initial commit: New Relic Synthetics as Code"

# Add remote and push
git remote add origin <your-repo-url>
git push -u origin main
```

**See [GITHUB_UPLOAD_CHECKLIST.md](GITHUB_UPLOAD_CHECKLIST.md) for detailed upload instructions.**

---

## ✅ Success Checklist

- [ ] Can view all monitors: `terraform state list`
- [ ] Can switch environments: `terraform workspace select dev|prod`
- [ ] Can deploy to dev: `terraform apply -var-file=terraform.tfvars.dev`
- [ ] Can deploy to prod: `terraform apply -var-file=terraform.tfvars.prod`
- [ ] Monitors visible in New Relic UI for both accounts
- [ ] Documentation reviewed and understood
- [ ] Repository committed to version control

---

## 💡 Pro Tips

- ✅ Always run `terraform plan` before `terraform apply`
- ✅ Test changes in dev before deploying to prod
- ✅ Use `terraform workspace show` to confirm environment
- ✅ Keep `generated.tf` in version control
- ✅ Never commit `*.tfvars` files (contains account IDs)
- ✅ Use environment variables for API keys
- ✅ Run `terraform fmt` to format code consistently

---

## 📞 Support

- **Repository Issues:** Create an issue in this repository
- **Terraform Provider Issues:** https://github.com/newrelic/terraform-provider-newrelic/issues
- **New Relic Support:** https://support.newrelic.com
- **Community Forum:** https://discuss.newrelic.com

---

**Ready to get started?** Choose your documentation path above and dive in! 🚀
