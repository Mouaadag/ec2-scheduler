# my-webApp EC2 Scheduler & Web Server

## 🎯 Objectif
Ce projet Terraform crée une infrastructure AWS automatisée pour gérer une instance EC2 avec un serveur web Apache, incluant une planification automatique de démarrage/arrêt.

## 🏗️ Architecture

L'infrastructure comprend :

- **Instance EC2** : Amazon Linux avec Apache HTTP Server
- **Page web** : Page d'accueil "Hello World" simple
- **Fonction Lambda** : Automatisation du démarrage/arrêt de l'instance
- **CloudWatch Events** : Planification automatique (8h-20h, lundi-vendredi)
- **Security Group** : Autorisation du trafic HTTP (port 80) et SSH (port 22)
- **IAM Roles** : Permissions sécurisées pour Lambda

## 🚀 Déploiement

### Prérequis

1. **AWS CLI configuré** avec les bonnes credentials
2. **Terraform** installé (version >= 1.0)
3. **Permissions AWS** pour créer EC2, Lambda, IAM, CloudWatch

### Configuration et déploiement

1. **Configurer les variables**
```bash
cp terraform.tfvars.example terraform.tfvars
# Modifier terraform.tfvars selon vos besoins
```

2. **Déployer l'infrastructure**
```bash
terraform init -upgrade
terraform plan
terraform apply
```

## 🌐 Accès au serveur web

Après déploiement, accédez à votre serveur via l'URL affichée dans les outputs Terraform :
```
http://<IP_PUBLIQUE_INSTANCE>
```

Vous verrez une page "Hello World" avec les informations de l'instance.

## 📋 Planification automatique

- **Démarrage** : Lundi-vendredi à 8h00 UTC
- **Arrêt** : Lundi-vendredi à 20h00 UTC

## 🔧 Gestion manuelle

### Tester la fonction Lambda
```bash
# Démarrer
aws lambda invoke --function-name start_stop_ec2 \
  --payload '{"action": "start"}' response.json

# Arrêter  
aws lambda invoke --function-name start_stop_ec2 \
  --payload '{"action": "stop"}' response.json
```

## Project Structure
```
my-webApp-ec2-scheduler/
├── main.tf                          # Ressources principales
├── variables.tf                     # Définition des variables
├── outputs.tf                       # Outputs du déploiement
├── providers.tf                     # Configuration des providers
├── terraform.tf                     # Backend Terraform Cloud
├── deploy.sh                        # Script de déploiement
├── switch-env.sh                    # Script de changement d'environnement
├── terraform.tfvars                 # Variables locales (ignoré par git)
├── terraform.tfvars.example         # Exemple de variables
├── environments/
│   ├── dev/
│   │   ├── backend.hcl              # Config backend dev
│   │   ├── terraform.tfvars         # Variables dev
│   │   └── terraform.tfvars.example # Exemple variables dev
│   ├── test/
│   │   ├── backend.hcl              # Config backend test
│   │   ├── terraform.tfvars         # Variables test
│   │   └── terraform.tfvars.example # Exemple variables test
│   └── release/
│       ├── backend.hcl              # Config backend release
│       ├── terraform.tfvars         # Variables release
│       └── terraform.tfvars.example # Exemple variables release
├── lambda/
│   └── start_stop_ec2.py            # Code de la fonction Lambda
├── .gitignore
└── README.md
```

## 🚀 Déploiement par environnement

### Utilisation des scripts

```bash
# Déployer en DEV
./deploy.sh dev

# Déployer en TEST  
./deploy.sh test

# Déployer en RELEASE
./deploy.sh release
```

### Switcher entre environnements

```bash
# Passer en mode DEV
./switch-env.sh dev

# Passer en mode TEST
./switch-env.sh test

# Passer en mode RELEASE
./switch-env.sh release
```

## 🎯 Avantages de cette approche

- **Isolation complète** : Chaque environnement a son propre workspace Terraform Cloud
- **Sécurité** : Impossible de toucher PROD par accident
- **Flexibilité** : Horaires différents par environnement
  - DEV : Arrêt à 18h (économies)
  - TEST : Arrêt à 20h  
  - RELEASE : Arrêt à 22h (production)
- **Traçabilité** : Historique complet dans Terraform Cloud
- **Collaboration** : Équipe peut travailler sur différents environnements simultanément

## Getting Started

### Prerequisites
- Terraform installed on your local machine.
- AWS account with appropriate permissions to manage EC2 instances.
- Python and pip installed for the Lambda function.

### Setup Instructions
1. Clone the repository:
   ```
   git clone <repository-url>
   cd scolio-ec2-scheduler
   ```

2. Configure your AWS credentials:
   Ensure your AWS credentials are set up in `~/.aws/credentials` or through environment variables.

3. Navigate to the desired environment:
   For development:
   ```
   cd environments/dev
   ```

4. Initialize Terraform:
   ```
   terraform init
   ```

5. Review the configuration:
   ```
   terraform plan
   ```

6. Apply the configuration:
   ```
   terraform apply
   ```

### Lambda Function
The Lambda function located in the `lambda` directory is responsible for starting and stopping EC2 instances based on a defined schedule. Ensure that the necessary permissions are granted to the Lambda function to manage EC2 instances.

### Contributing
Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

### License
This project is licensed under the MIT License. See the LICENSE file for details.