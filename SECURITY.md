# Security Guidelines

This document outlines security best practices for managing sensitive data in this repository.

---

## 🔒 Sensitive Data Protection

### What Should NEVER Be Committed

❌ **New Relic API Keys** (NRAK-*)
❌ **New Relic License Keys** (NRAL-*, NRII-*)
❌ **Account IDs** (in tfvars files)
❌ **Terraform State Files** (*.tfstate)
❌ **Provider Configuration** (provider.tf with hardcoded credentials)
❌ **Any credentials or secrets**

### What Can Be Committed

✅ **Terraform Configuration** (generated.tf with variables)
✅ **Variable Definitions** (variables.tf)
✅ **Example Files** (*.example)
✅ **Documentation** (*.md)
✅ **Scripts** (that read from environment variables)
✅ **.gitignore** file

---

## 🛡️ Implemented Security Measures

### 1. Environment Variables for API Keys

All scripts now use environment variables instead of hardcoded credentials:

```bash
# Set before running any script
export NEW_RELIC_API_KEY="your-api-key-here"
export NEW_RELIC_ACCOUNT_ID="your-account-id"
```

### 2. Gitignore Configuration

The `.gitignore` file blocks:
- `*.tfvars` (except `.example` files)
- `provider.tf` (contains account references)
- `terraform.tfstate*` (contains resource IDs)
- `*.backup` (may contain sensitive data)

### 3. Secure Credentials in Synthetics

Monitor scripts use New Relic's secure credential storage:

```javascript
// Instead of hardcoded:
const apiKey = 'NRAK-XXXXX';  // ❌ Never do this

// Use secure credentials:
const apiKey = $secure.NR_API_KEY;  // ✅ Correct way
```

### 4. Example Files

Template files provided with placeholders:
- `terraform.tfvars.example`
- `provider.tf.example`

---

## 📋 Pre-Commit Checklist

Before committing code, verify:

- [ ] No API keys present (`grep -r "NRAK-" .`)
- [ ] No license keys present (`grep -r "NRAL-\|NRII-" .`)
- [ ] Account IDs only in variables or examples
- [ ] All `.tfvars` files are gitignored
- [ ] `provider.tf` is gitignored
- [ ] State files are gitignored

---

## 🔍 Scan for Secrets

### Manual Check

```bash
# Search for API keys
grep -r "NRAK-" . --exclude-dir=.git --exclude="SECURITY.md"

# Search for license keys
grep -r "NRAL-\|NRII-" . --exclude-dir=.git

# Search for account IDs in non-example files
grep -r "account_id = [0-9]" . --exclude="*.example" --exclude-dir=.git --exclude-dir=.terraform
```

### Automated Check Script

Create `check-secrets.sh`:

```bash
#!/bin/bash
echo "🔍 Scanning for secrets..."

# Check for API keys
if grep -r "NRAK-[A-Z0-9]" . --exclude-dir=.git --exclude="SECURITY.md" --exclude="*.md" > /dev/null; then
    echo "❌ Found API keys in files!"
    grep -r "NRAK-" . --exclude-dir=.git --exclude="SECURITY.md" --exclude="*.md"
    exit 1
fi

# Check for hardcoded account IDs in tfvars
if [ -f "terraform.tfvars.prod" ] || [ -f "terraform.tfvars.dev" ]; then
    echo "❌ Found tfvars files that should be gitignored!"
    exit 1
fi

# Check for state files
if ls terraform.tfstate* 1> /dev/null 2>&1; then
    echo "❌ Found state files that should be gitignored!"
    exit 1
fi

echo "✅ No secrets found. Safe to commit!"
```

Make it executable:
```bash
chmod +x check-secrets.sh
```

Run before every commit:
```bash
./check-secrets.sh && git commit
```

---

## 🔐 Using Secure Credentials

### In Python Scripts

```python
import os

# ✅ Correct: Read from environment
api_key = os.environ.get("NEW_RELIC_API_KEY")
account_id = os.environ.get("NEW_RELIC_ACCOUNT_ID")

# ❌ Never do this:
api_key = "NRAK-XXXXX"
```

### In Terraform

```hcl
# ✅ Correct: Use variables
provider "newrelic" {
  account_id = var.account_id
  # API key from NEW_RELIC_API_KEY environment variable
  region = var.region
}

# ❌ Never do this:
provider "newrelic" {
  account_id = 1234567
  api_key    = "NRAK-XXXXX"
}
```

### In Synthetic Monitor Scripts

```javascript
// ✅ Correct: Use secure credentials
const apiKey = $secure.NR_API_KEY;
const licenseKey = $secure.NR_LICENSE_KEY;

// ❌ Never do this:
const apiKey = 'NRAK-XXXXX';
```

To set secure credentials in New Relic:
1. Go to **Synthetic Monitoring → Secure credentials**
2. Click **Create secure credential**
3. Name: `NR_API_KEY`, Value: Your API key
4. Use in scripts as `$secure.NR_API_KEY`

---

## 🚨 If Credentials Are Leaked

If you accidentally commit credentials:

### 1. Immediately Revoke the Key
- Go to New Relic → API Keys
- Delete the leaked key
- Generate a new one

### 2. Remove from Git History

```bash
# Remove sensitive file from history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/sensitive/file" \
  --prune-empty --tag-name-filter cat -- --all

# Force push (⚠️ coordinate with team)
git push origin --force --all
```

### 3. Notify Security Team
- Report the incident to your security team
- Document what was exposed and for how long
- Audit for any unauthorized access

---

## 📚 Additional Resources

- **New Relic API Keys:** https://docs.newrelic.com/docs/apis/intro-apis/new-relic-api-keys/
- **Secure Credentials:** https://docs.newrelic.com/docs/synthetics/synthetic-monitoring/using-monitors/store-secure-credentials-scripted-browsers-api-tests/
- **GitHub Secret Scanning:** https://docs.github.com/en/code-security/secret-scanning
- **git-secrets Tool:** https://github.com/awslabs/git-secrets

---

## ✅ Summary

**Golden Rules:**
1. Never commit actual API keys or account credentials
2. Use environment variables for sensitive data
3. Always check `.gitignore` is properly configured
4. Scan for secrets before every commit
5. Use New Relic's secure credential storage for monitor scripts
6. Provide `.example` files for configuration templates

**When in doubt, use environment variables!**
