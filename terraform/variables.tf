# ID du projet GCP 
variable "project_id" {
  description = "ID du projet GCP"
  type        = string
}

# Région et zone par défaut
variable "region" {
  default     = "europe-west9"
}

variable "zone" {
  default     = "europe-west9-b"
}

# IP publique autorisée à accéder à Grafana
variable "allowed_ip" {
  description = "Adresse IP publique autorisée"
  type        = string
}

# Utilisateur GitHub (pour cloner ton dépôt depuis la VM)
variable "github_user" {
  description = "ahamdouch"
  type        = string
}

# Nom du dépôt contenant docker-compose.yml
variable "github_repo" {
  description = "Use-Case"
  type        = string
}
