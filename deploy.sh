#!/bin/bash

# Deployment helper script for New Relic Synthetic monitors
# Usage: ./deploy.sh [prod|dev] [plan|apply|destroy]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check arguments
if [ $# -lt 1 ]; then
    print_error "Usage: $0 [prod|dev] [plan|apply|destroy]"
    echo ""
    echo "Examples:"
    echo "  $0 dev plan      # Plan deployment to dev"
    echo "  $0 dev apply     # Deploy to dev"
    echo "  $0 prod apply    # Deploy to prod"
    echo "  $0 dev destroy   # Destroy dev monitors"
    exit 1
fi

ENVIRONMENT=$1
ACTION=${2:-plan}  # Default to 'plan' if not specified

# Validate environment
if [ "$ENVIRONMENT" != "prod" ] && [ "$ENVIRONMENT" != "dev" ]; then
    print_error "Environment must be 'prod' or 'dev'"
    exit 1
fi

# Validate action
if [ "$ACTION" != "plan" ] && [ "$ACTION" != "apply" ] && [ "$ACTION" != "destroy" ]; then
    print_error "Action must be 'plan', 'apply', or 'destroy'"
    exit 1
fi

# Check if API key is set
if [ -z "$NEW_RELIC_API_KEY" ]; then
    print_error "NEW_RELIC_API_KEY environment variable is not set"
    echo ""
    echo "Set it with:"
    echo "  export NEW_RELIC_API_KEY=\"your-api-key\""
    exit 1
fi

# Confirm workspace exists or create it
print_info "Setting up workspace: $ENVIRONMENT"
if ! terraform workspace list | grep -q "$ENVIRONMENT"; then
    print_warning "Workspace '$ENVIRONMENT' does not exist. Creating it..."
    terraform workspace new "$ENVIRONMENT"
else
    terraform workspace select "$ENVIRONMENT"
fi

CURRENT_WORKSPACE=$(terraform workspace show)
print_info "Current workspace: $CURRENT_WORKSPACE"

# Set the var file
VAR_FILE="terraform.tfvars.$ENVIRONMENT"

if [ ! -f "$VAR_FILE" ]; then
    print_error "Variable file not found: $VAR_FILE"
    exit 1
fi

print_info "Using variable file: $VAR_FILE"

# Show confirmation for destructive actions
if [ "$ACTION" = "apply" ] || [ "$ACTION" = "destroy" ]; then
    print_warning "About to $ACTION to $ENVIRONMENT environment"
    read -p "Are you sure? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
        print_info "Cancelled by user"
        exit 0
    fi
fi

# Execute terraform command
print_info "Running: terraform $ACTION -var-file=$VAR_FILE"
echo ""

if [ "$ACTION" = "apply" ] || [ "$ACTION" = "destroy" ]; then
    terraform "$ACTION" -var-file="$VAR_FILE" -auto-approve
else
    terraform "$ACTION" -var-file="$VAR_FILE"
fi

# Print summary
echo ""
print_info "✅ Terraform $ACTION completed successfully for $ENVIRONMENT"

if [ "$ACTION" = "plan" ]; then
    echo ""
    print_info "To apply these changes, run:"
    echo "  $0 $ENVIRONMENT apply"
fi
