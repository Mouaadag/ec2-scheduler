#!/bin/bash

# Mise à jour du système et installation d'Apache
yum update -y
yum install -y httpd

# Démarrage et activation d'Apache
systemctl start httpd
systemctl enable httpd

# Création du répertoire pour les assets web s'il n'existe pas
mkdir -p /var/www/html/api

# Création du fichier HTML principal avec le contenu généré par Terraform
cat > /var/www/html/index.html << 'HTML_EOF'
${html_content}
HTML_EOF

# Création du fichier CSS
cat > /var/www/html/styles.css << 'CSS_EOF'
${css_content}
CSS_EOF

# Création d'un fichier JSON pour les métadonnées dynamiques (accessible via AJAX)
cat > /var/www/html/api/server-info.json << 'JSON_EOF'
{
    "instance_id": "$(curl -s http://169.254.169.254/latest/meta-data/instance-id)",
    "instance_type": "$(curl -s http://169.254.169.254/latest/meta-data/instance-type)",
    "availability_zone": "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)",
    "local_ip": "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)",
    "public_ip": "$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)",
    "last_update": "$(date)",
    "instance_name": "${instance_name}"
}
JSON_EOF

# Configuration des permissions
chown -R apache:apache /var/www/html/
chmod -R 644 /var/www/html/*
chmod 755 /var/www/html/
chmod 755 /var/www/html/api/

# Redémarrage d'Apache pour s'assurer que tout fonctionne
systemctl restart httpd

# Log de fin d'installation
echo "$(date): Installation du serveur web ${instance_name} terminée" >> /var/log/webapp-setup.log
echo "HTML content length: $(wc -c < /var/www/html/index.html)" >> /var/log/webapp-setup.log
