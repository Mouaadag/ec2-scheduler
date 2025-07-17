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

echo "📋 Planning for $ENVIRONMENT environment..."

# Définir le workspace Terraform Cloud
export TF_WORKSPACE="my-webApp-$ENVIRONMENT"

# Nettoyer l'état local
rm -rf .terraform/

# Initialiser Terraform Cloud
echo "🔧 Initializing Terraform Cloud with workspace: $TF_WORKSPACE..."
terraform init

# Planifier SEULEMENT avec les bonnes variables
echo "📊 Planning deployment for $ENVIRONMENT..."
terraform plan -var-file="environments/$ENVIRONMENT/terraform.tfvars"

echo "✅ Plan completed for $ENVIRONMENT environment!"
echo "💡 To apply these changes, run: ./deploy.sh $ENVIRONMENT"
