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

echo "🚀 Deploying to $ENVIRONMENT environment..."

# Définir le workspace Terraform Cloud
export TF_WORKSPACE="my-webApp-$ENVIRONMENT"

# Nettoyer l'état local
rm -rf .terraform/

# Initialiser Terraform Cloud
echo "📋 Initializing Terraform Cloud with workspace: $TF_WORKSPACE..."
terraform init

# Planifier avec les bonnes variables
echo "📋 Planning deployment..."
terraform plan -var-file="environments/$ENVIRONMENT/terraform.tfvars"

# Demander confirmation
read -p "🤔 Do you want to apply these changes? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "✅ Applying changes..."
    terraform apply -var-file="environments/$ENVIRONMENT/terraform.tfvars"
    echo "🎉 Deployment completed!"
else
    echo "❌ Deployment cancelled."
fi
