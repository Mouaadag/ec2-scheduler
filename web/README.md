# Structure Web - my-webApp

Ce dossier contient les assets web pour l'application my-webApp.

## Fichiers

### `index.html.tpl`
- Template HTML principal utilisé par Terraform
- Contient des variables Terraform (`${instance_name}`)
- Sera généré automatiquement lors du déploiement

### `styles.css`
- Feuille de style CSS pour l'interface web
- Design moderne avec gradient et animations
- Responsive design pour mobile et desktop

### `setup.sh`
- Script bash d'initialisation du serveur web
- Installe Apache, copie les fichiers HTML/CSS
- Génère un fichier JSON avec les métadonnées EC2
- Exécuté automatiquement via `user_data`

### `index.html`
- Version statique du HTML (pour référence)
- Sera remplacée par la version générée via le template

## Fonctionnalités

1. **Page web dynamique** : Affiche les informations de l'instance EC2
2. **API JSON locale** : Endpoint `/api/server-info.json` pour les métadonnées
3. **Auto-refresh** : Les informations se mettent à jour automatiquement
4. **Design moderne** : Interface responsive avec animations

## Workflow de déploiement

1. Terraform lit le template `index.html.tpl`
2. Terraform génère le fichier HTML final avec les variables
3. Le script `setup.sh` est exécuté sur l'instance EC2
4. Apache est configuré et les fichiers web sont copiés
5. L'API JSON est générée avec les vraies métadonnées EC2

## Accès

Une fois déployé, l'application est accessible via :
- `http://<PUBLIC_IP>/` - Page principal
- `http://<PUBLIC_IP>/api/server-info.json` - API métadonnées
- `http://<PUBLIC_IP>/styles.css` - Feuille de style
