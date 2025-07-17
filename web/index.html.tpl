<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Serveur Web ${instance_name}</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <div class="container">
        <h1>🌟 Hello World - Serveur ${instance_name}! 🌟</h1>
        
        <div class="info-box server-info">
            <h3>📊 Informations du serveur</h3>
            <p class="metadata"><strong>Instance ID:</strong> <span id="instance-id" class="loading">Chargement...</span></p>
            <p class="metadata"><strong>Type d'instance:</strong> <span id="instance-type" class="loading">Chargement...</span></p>
            <p class="metadata"><strong>Zone de disponibilité:</strong> <span id="availability-zone" class="loading">Chargement...</span></p>
            <p class="metadata"><strong>IP locale:</strong> <span id="local-ip" class="loading">Chargement...</span></p>
            <p class="metadata"><strong>IP publique:</strong> <span id="public-ip" class="loading">Chargement...</span></p>
            <button class="refresh-btn" onclick="loadMetadata()">🔄 Actualiser les infos</button>
        </div>
        
        <div class="info-box schedule-info">
            <h3>🕒 Planification automatique</h3>
            <p><strong>Semaine:</strong> Démarrage 6h UTC (8h Paris) • Arrêt 20h UTC (22h Paris)</p>
            <p><strong>Weekend:</strong> Démarrage 8h UTC (10h Paris) • Arrêt 18h UTC (20h Paris)</p>
            <p class="status">✅ Serveur actuellement en ligne!</p>
        </div>
        
        <div class="info-box footer">
            <p><em>Dernière mise à jour: <span id="last-update" class="loading">Chargement...</span></em></p>
        </div>
    </div>

    <script>
        // Fonction pour récupérer les métadonnées depuis l'API locale
        async function loadMetadata() {
            try {
                // Mise à jour de l'heure
                document.getElementById('last-update').textContent = new Date().toLocaleString('fr-FR');
                
                // Récupération des données depuis l'API locale JSON
                const response = await fetch('/api/server-info.json');
                if (response.ok) {
                    const data = await response.json();
                    
                    document.getElementById('instance-id').textContent = data.instance_id || 'Non disponible';
                    document.getElementById('instance-type').textContent = data.instance_type || 'Non disponible';
                    document.getElementById('availability-zone').textContent = data.availability_zone || 'Non disponible';
                    document.getElementById('local-ip').textContent = data.local_ip || 'Non disponible';
                    document.getElementById('public-ip').textContent = data.public_ip || 'Non disponible';
                    
                    // Retirer la classe loading
                    document.querySelectorAll('.loading').forEach(el => el.classList.remove('loading'));
                } else {
                    throw new Error('Impossible de charger les métadonnées depuis l\'API locale');
                }
                
            } catch (error) {
                console.error('Erreur lors du chargement des métadonnées:', error);
                
                // Fallback: essayer d'accéder directement aux métadonnées EC2
                try {
                    const metadataRequests = [
                        fetch('http://169.254.169.254/latest/meta-data/instance-id'),
                        fetch('http://169.254.169.254/latest/meta-data/instance-type'),
                        fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone'),
                        fetch('http://169.254.169.254/latest/meta-data/local-ipv4'),
                        fetch('http://169.254.169.254/latest/meta-data/public-ipv4')
                    ];
                    
                    const responses = await Promise.allSettled(metadataRequests);
                    const [instanceId, instanceType, az, localIp, publicIp] = await Promise.all(
                        responses.map(async (response) => {
                            if (response.status === 'fulfilled' && response.value.ok) {
                                return await response.value.text();
                            }
                            return 'Indisponible';
                        })
                    );

                    document.getElementById('instance-id').textContent = instanceId;
                    document.getElementById('instance-type').textContent = instanceType;
                    document.getElementById('availability-zone').textContent = az;
                    document.getElementById('local-ip').textContent = localIp;
                    document.getElementById('public-ip').textContent = publicIp;
                    
                } catch (fallbackError) {
                    console.error('Erreur fallback:', fallbackError);
                    document.querySelectorAll('#instance-id, #instance-type, #availability-zone, #local-ip, #public-ip')
                        .forEach(el => el.textContent = 'Erreur de chargement');
                }
                
                // Retirer la classe loading dans tous les cas
                document.querySelectorAll('.loading').forEach(el => el.classList.remove('loading'));
            }
        }

        // Charger les métadonnées au chargement de la page
        document.addEventListener('DOMContentLoaded', loadMetadata);
        
        // Auto-refresh toutes les 60 secondes
        setInterval(loadMetadata, 60000);
    </script>
</body>
</html>
