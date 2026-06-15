#!/bin/bash

# Security check script - Run before committing to Git
# This script scans for common secrets and sensitive data

echo "🔍 Scanning for secrets and sensitive data..."
echo ""

ERRORS=0

# Check for API keys
echo "[1/5] Checking for New Relic API keys..."
if grep -r "NRAK-[A-Z0-9]\{30,\}" . \
    --exclude-dir=.git \
    --exclude-dir=.terraform \
    --exclude="SECURITY.md" \
    --exclude="*.md" \
    --exclude="check-secrets.sh" > /dev/null 2>&1; then
    echo "❌ Found API keys in files:"
    grep -rn "NRAK-" . --exclude-dir=.git --exclude-dir=.terraform --exclude="SECURITY.md" --exclude="*.md" --exclude="check-secrets.sh"
    ERRORS=$((ERRORS+1))
else
    echo "✅ No API keys found"
fi

# Check for license keys
echo "[2/5] Checking for New Relic license keys..."
if grep -r "NRAL-\|NRII-" . \
    --exclude-dir=.git \
    --exclude-dir=.terraform \
    --exclude="*.md" \
    --exclude="check-secrets.sh" > /dev/null 2>&1; then
    echo "❌ Found license keys in files:"
    grep -rn "NRAL-\|NRII-" . --exclude-dir=.git --exclude-dir=.terraform --exclude="*.md" --exclude="check-secrets.sh"
    ERRORS=$((ERRORS+1))
else
    echo "✅ No license keys found"
fi

# Check for tfvars files
echo "[3/5] Checking for uncommitted tfvars files..."
if git ls-files --error-unmatch terraform.tfvars.prod 2>/dev/null || \
   git ls-files --error-unmatch terraform.tfvars.dev 2>/dev/null; then
    echo "❌ Found tfvars files that should be gitignored!"
    echo "   These files contain account IDs and should not be committed."
    ERRORS=$((ERRORS+1))
else
    echo "✅ No sensitive tfvars files tracked"
fi

# Check for state files
echo "[4/5] Checking for Terraform state files..."
if git ls-files --error-unmatch "terraform.tfstate*" 2>/dev/null; then
    echo "❌ Found state files that should be gitignored!"
    echo "   Terraform state may contain sensitive resource IDs."
    ERRORS=$((ERRORS+1))
else
    echo "✅ No state files tracked"
fi

# Check for provider.tf with credentials
echo "[5/5] Checking provider.tf for hardcoded credentials..."
if [ -f "provider.tf" ] && git ls-files --error-unmatch provider.tf 2>/dev/null; then
    if grep -E "api_key.*=.*[\"']NRAK-" provider.tf > /dev/null 2>&1; then
        echo "❌ Found hardcoded API key in provider.tf!"
        ERRORS=$((ERRORS+1))
    else
        echo "⚠️  provider.tf is tracked but appears safe"
    fi
else
    echo "✅ provider.tf not tracked"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $ERRORS -eq 0 ]; then
    echo "✅ All checks passed! Safe to commit."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
else
    echo "❌ Found $ERRORS issue(s). Please fix before committing."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "💡 Tips:"
    echo "   - Remove sensitive data from files"
    echo "   - Use environment variables instead"
    echo "   - Check .gitignore is properly configured"
    echo "   - Review SECURITY.md for guidelines"
    exit 1
fi
