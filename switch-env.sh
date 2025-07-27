#!/bin/bash

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

echo "Switching to $ENVIRONMENT environment..."

# Définir le workspace Terraform Cloud
export TF_WORKSPACE="my-webApp-$ENVIRONMENT"

# Nettoyer l'état local
rm -rf .terraform/

# Initialiser Terraform Cloud
terraform init

echo "Successfully switched to $ENVIRONMENT environment"
echo "Current workspace: $TF_WORKSPACE"
echo "Workspace will be active for this terminal session"
echo "To make it permanent, add 'export TF_WORKSPACE=my-webApp-$ENVIRONMENT' to your shell profile"
