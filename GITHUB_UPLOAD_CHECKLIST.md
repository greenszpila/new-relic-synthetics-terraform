# GitHub Upload Checklist

This checklist ensures all sensitive data has been removed before uploading to GitHub.

---

## ✅ Security Measures Completed

### 1. API Keys Removed
- ✅ `get-all-synthetics-guid.py` now uses environment variables
- ✅ `generated.tf` uses `$secure.NR_API_KEY` for monitor scripts
- ✅ No hardcoded API keys remain in code

### 2. Account IDs Secured
- ✅ `terraform.tfvars.prod` is gitignored
- ✅ `terraform.tfvars.dev` is gitignored
- ✅ Account IDs in scripts replaced with placeholders
- ✅ Example files created with placeholders

### 3. Files Properly Gitignored
```
✅ *.tfvars (contains account IDs)
✅ provider.tf (contains account references)
✅ terraform.tfstate* (contains resource IDs)
✅ *.backup (may contain sensitive data)
```

### 4. Security Tools Created
- ✅ `SECURITY.md` - Complete security guide
- ✅ `check-secrets.sh` - Pre-commit security scanner
- ✅ `.gitignore` - Comprehensive exclusion rules

### 5. Example Files Provided
- ✅ `terraform.tfvars.example` - Template with placeholders
- ✅ `provider.tf.example` - Template for provider config

---

## 🔍 Pre-Upload Verification

Run these commands before pushing to GitHub:

### 1. Run Security Scanner
```bash
./check-secrets.sh
```

**Expected output:** "✅ All checks passed! Safe to commit."

### 2. Manual Verification
```bash
# Check for API keys
grep -r "NRAK-" . --exclude-dir=.git --exclude="SECURITY.md" --exclude="*.md"
# Should return: no results

# Check for license keys
grep -r "NRAL-\|NRII-" . --exclude-dir=.git --exclude="*.md" --exclude="check-secrets.sh"
# Should return: no results

# Verify gitignore is working
git status
# Should NOT show: *.tfvars, provider.tf, terraform.tfstate*
```

### 3. Verify Example Files
```bash
# Check example files exist
ls -la *.example
# Should show: terraform.tfvars.example, provider.tf.example
```

### 4. Test Environment Variables
```bash
# Verify scripts use environment variables
grep "os.environ" get-all-synthetics-guid.py
# Should show: API key and account ID from env vars

grep "\$secure" generated.tf
# Should show: $secure.NR_API_KEY
```

---

## 📝 What Will Be Public

### Safe to Upload
- ✅ All `.md` documentation files
- ✅ `generated.tf` (monitor configs using variables)
- ✅ `variables.tf` (variable definitions)
- ✅ Python scripts (using environment variables)
- ✅ `check-secrets.sh` (security scanner)
- ✅ `.gitignore` file
- ✅ Example files (`*.example`)
- ✅ Example scripts directory

### Will NOT Be Uploaded (Gitignored)
- ❌ `terraform.tfvars.prod` (your production account ID)
- ❌ `terraform.tfvars.dev` (your dev account ID)
- ❌ `provider.tf` (references your accounts)
- ❌ `terraform.tfstate*` (resource IDs and metadata)
- ❌ `.terraform/` directory (Terraform working files)
- ❌ `*.backup` files (may contain old sensitive data)

---

## 🚀 Upload Steps

### 1. Initialize Git Repository (if not done)
```bash
git init
```

### 2. Review .gitignore
```bash
cat .gitignore
# Verify it includes all sensitive file patterns
```

### 3. Run Security Check
```bash
./check-secrets.sh
```

### 4. Stage Files
```bash
# Add safe files
git add *.md
git add *.py
git add generated.tf
git add variables.tf
git add *.example
git add check-secrets.sh
git add .gitignore
git add example_scripts/

# DO NOT add:
# git add terraform.tfvars.* (unless *.example)
# git add provider.tf (unless .example)
# git add *.tfstate*
```

### 5. Review Staged Changes
```bash
git status
git diff --cached
```

### 6. Commit
```bash
git commit -m "Initial commit: New Relic Synthetics as Code

- Export synthetic monitors from New Relic to Terraform
- Multi-environment support (prod/dev)
- Comprehensive documentation
- Security measures implemented
- All sensitive data removed"
```

### 7. Create GitHub Repository
```bash
# On GitHub, create a new repository
# Then link it:
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git
```

### 8. Push to GitHub
```bash
git push -u origin main
```

---

## 📖 README for GitHub

Suggested content for your GitHub repository README:

```markdown
# New Relic Synthetic Monitors as Code

Manage New Relic Synthetic monitors using Terraform for Infrastructure as Code.

## Features

- ✅ Export all synthetic monitors from New Relic
- ✅ Manage monitors as Terraform code
- ✅ Multi-environment support (prod/dev/staging)
- ✅ Version controlled and reproducible
- ✅ Complete documentation included

## Quick Start

1. Set up credentials:
   ```bash
   export NEW_RELIC_API_KEY="your-api-key"
   export NEW_RELIC_ACCOUNT_ID="your-account-id"
   ```

2. Fetch monitors:
   ```bash
   python3 get-all-synthetics-guid.py
   ```

3. Import to Terraform:
   ```bash
   terraform init
   terraform plan -generate-config-out=generated.tf
   ```

4. Deploy to dev:
   ```bash
   terraform workspace new dev
   terraform apply -var-file=terraform.tfvars.dev
   ```

## Documentation

- **[Complete Guide](COMPLETE_GUIDE.md)** - Step-by-step instructions
- **[Quick Reference](CHEAT_SHEET.md)** - Common commands
- **[Security Guide](SECURITY.md)** - Security best practices
- **[Start Here](README_START_HERE.md)** - Overview and navigation

## Security

This repository does not contain any sensitive data. All API keys and account IDs are:
- Loaded from environment variables
- Stored in gitignored files
- Referenced via placeholders in examples

See [SECURITY.md](SECURITY.md) for details.

## License

[Your License Here]
```

---

## ⚠️ Important Reminders

### Before Every Push
1. ✅ Run `./check-secrets.sh`
2. ✅ Review `git status` for unexpected files
3. ✅ Check `git diff --cached` before commit
4. ✅ Never force-push if you've already pushed secrets

### If You Accidentally Push Secrets
1. **Immediately revoke** the exposed credentials in New Relic
2. **Remove from history** using git-filter-branch or BFG
3. **Notify** your security team
4. See [SECURITY.md](SECURITY.md) for detailed recovery steps

### Regular Maintenance
- Run security scanner before each commit
- Review `.gitignore` when adding new file types
- Update documentation when changing sensitive data handling
- Periodically rotate API keys as security best practice

---

## ✅ Final Verification

Before pushing, confirm:

- [ ] Ran `./check-secrets.sh` successfully
- [ ] No API keys in any files (`grep -r "NRAK-"`)
- [ ] No license keys in any files (`grep -r "NRAL-\|NRII-"`)
- [ ] `.tfvars` files are gitignored
- [ ] `provider.tf` is gitignored
- [ ] State files are gitignored
- [ ] Example files have placeholders only
- [ ] Documentation is complete
- [ ] Security guide is included
- [ ] Git status shows only intended files

---

## 🎉 Ready to Upload!

Your repository is now secure and ready to be pushed to GitHub.

**Command to push:**
```bash
git push -u origin main
```

**After upload, verify on GitHub:**
- Check no sensitive files are visible
- Review file contents in browser
- Ensure .gitignore is working
- Test cloning to a fresh directory

---

**Questions?** See [SECURITY.md](SECURITY.md) for additional guidance.
