# Use-Case
Use case SRE
1.1 Obtenir des ETH gratuits sur Sepolia  
J’ai utilisé MetaMask pour créer un wallet Ethereum sur le testnet Sepolia, puis j’ai récupéré gratuitement des ETH via le faucet de Google Cloud :

🔗 https://cloud.google.com/application/web3/faucet/ethereum

L’adresse utilisée dans ce projet est :
0x38A69be581e52BDDf6c3ED4bd0DbFA8BEaA08930

1.2 Exporter le solde ETH avec ethexporter  
J’ai utilisé l’image Docker officielle hunterlong/ethexporter qui expose le solde ETH d’un wallet via une interface compatible Prometheus. Elle tourne dans un conteneur Docker, accessible sur le port 9100.

1.3 Ajout de Prometheus pour scrapper le solde toutes les 20 secondes  
J’ai intégré un conteneur Prometheus dans le même docker-compose.yml.  
La configuration est montée depuis prometheus.yml, où j’ai défini un scrape_interval de 20 secondes.

Prometheus scrappe :

- le service ethexporter  
- son propre endpoint

1.4 Création d’un dashboard Grafana pour suivre le solde  
J’ai configuré Grafana avec provisioning automatique :

- La datasource Prometheus est provisionnée au démarrage  
- Un dashboard nommé "Eth Balance Dashboard" est chargé automatiquement  
- Le dashboard affiche une courbe eth_balance_ether dans le temps

1.5 Restriction d’accès avec Traefik et IP whitelist  
J’ai intégré Traefik comme reverse proxy sécurisé, avec les éléments suivants :

- Routage du trafic HTTPS vers Grafana  
- Restriction à une seule adresse IP publique (la mienne) via un middleware ip-whitelist  
- Certificats Let’s Encrypt générés automatiquement

1.6 Prévention de la perte de données  
J’ai utilisé des volumes Docker persistants pour :

- les données Prometheus  
- les données Grafana (dashboards, users, config)

Cela permet de recréer la stack sans perte d’historique.

1.7 Support HTTPS  
Le support HTTPS est assuré via Traefik + Let's Encrypt, avec un certificat automatique associé à mon adresse email.  
La configuration TLS est active sur le port 443 avec un résolveur ACME (certresolver=le).

1.8 Améliorations possibles  
Voici quelques pistes d’amélioration :

- Ajouter Alertmanager pour recevoir des alertes quand le solde passe sous un seuil  
- Support multi-wallet pour surveiller plusieurs adresses en parallèle  
- Monitoring complémentaire via Loki pour logs, ou Tempo pour traces  

2. Infrastructure as Code  
2.1 Qu’est-ce que l’Infrastructure as Code ?  
L’Infrastructure as Code (IaC) est une méthode de gestion de l’infrastructure via du code déclaratif.  
Elle permet de versionner, automatiser, tester, et reproduire facilement un environnement technique.  
Elle s’appuie souvent sur des outils comme :

- Terraform (infrastructure)  
- Ansible (configuration)

2.2 Exemple Terraform pour GCP  
J’ai inclus un exemple de fichier Terraform (dans le dossier terraform/) qui :

- Crée une VM sur GCP  
- Installe Docker et Docker Compose  

Ce script permet de déployer automatiquement toute la stack sur le cloud.

2.3 CI/CD avec GitHub Actions  
J’ai défini un fichier basique .github/workflows/deploy.yml qui :

- Se déclenche à chaque push sur la branche main  
- Exécute terraform apply pour redéployer l’infra automatiquement

On peut facilement l’étendre pour ajouter :

- des tests de syntaxe Docker/Prometheus  
- du provisioning Grafana automatisé  
- des vérifications de certificats TLS