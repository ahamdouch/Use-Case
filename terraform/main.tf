# Configuration du provider Google Cloud
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Déclaration d'une VM Debian 12 avec Docker + Docker Compose
resource "google_compute_instance" "eth-monitoring" {
  name         = "eth-monitoring-instance"
  machine_type = "e2-medium" # taille modérée pour usage léger
  zone         = var.zone

  # Disque d'amorçage avec l'image officielle Debian
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 20
    }
  }

  # Interface réseau et IP publique
  network_interface {
    network = "default"
    access_config {}
  }

  # Script de démarrage : installe Docker, clone ton repo et lance Docker Compose
  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt update && apt install -y docker.io docker-compose git
    usermod -aG docker $${USER}
    git clone https://github.com/${var.github_user}/${var.github_repo}.git
    cd ${var.github_repo}
    docker-compose up -d
  EOT

  tags = ["eth-monitoring"]
}

# Règle de firewall pour autoriser le trafic HTTP, HTTPS, Grafana et Prometheus
resource "google_compute_firewall" "allow-https-http" {
  name    = "allow-https-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "3000", "9090"]
  }

  # Seule mon adresse IP publique est autorisée
  source_ranges = [var.allowed_ip]
}

# Affichage de l'IP publique de la VM à la fin
output "instance_ip" {
  value = google_compute_instance.eth-monitoring.network_interface[0].access_config[0].nat_ip
}
