#!/bin/bash

set -e

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment>"
    echo "Available environments: dev, test, release"
    exit 1
fi

if [ ! -d "environments/$ENVIRONMENT" ]; then
    echo "Environment '$ENVIRONMENT' not found!"
    exit 1
fi

echo "🚨 DESTROYING $ENVIRONMENT environment..."

# Définir le workspace Terraform Cloud
export TF_WORKSPACE="my-webApp-$ENVIRONMENT"

# Nettoyer l'état local
rm -rf .terraform/

# Initialiser Terraform Cloud
echo "🔧 Initializing Terraform Cloud with workspace: $TF_WORKSPACE..."
terraform init

# Planifier la destruction
echo "📋 Planning destruction for $ENVIRONMENT..."
terraform plan -destroy -var-file="environments/$ENVIRONMENT/terraform.tfvars"

# Demander confirmation
echo "🚨 WARNING: This will DESTROY all resources in $ENVIRONMENT environment!"
read -p "🤔 Are you sure you want to destroy $ENVIRONMENT? Type 'yes' to confirm: " -r

if [[ $REPLY == "yes" ]]; then
    echo "💥 Destroying infrastructure..."
    terraform destroy -var-file="environments/$ENVIRONMENT/terraform.tfvars"
    echo "✅ $ENVIRONMENT environment destroyed!"
else
    echo "❌ Destruction cancelled."
fi