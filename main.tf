# --- CONFIGURATION DU PROJET ---
provider "google" {
  project = "project-769ef3f4-eb92-4235-a86"
  region  = "us-central1"
}

# --- SECRET MANAGER (Clés API Proball) ---
resource "google_secret_manager_secret" "api_key" {
  secret_id = "proball-api-keys"
  replication {
    auto {}
  }
}

# --- BASE DE DONNÉES TEMPS RÉEL (Firestore) ---
resource "google_firestore_database" "database" {
  name        = "proball-db"
  location_id = "us-central1"
  type        = "FIRESTORE_NATIVE"
}

# --- BACKEND PROBALL (Calculs et IA) ---
resource "google_cloud_run_v2_service" "backend" {
  name     = "proball-backend"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      env {
        name  = "FIRESTORE_DB"
        value = "proball-db"
      }
    }
  }
}

# --- FRONTEND PROBALL (Le site web Proball) ---
resource "google_cloud_run_v2_service" "frontend" {
  name     = "proball-site"
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
  }
}

# --- DÉCLENCHEUR AUTOMATIQUE ---
resource "google_cloudbuild_trigger" "deploy_trigger" {
  name     = "deploy-proball-app"
  location = "us-central1"

  github {
    owner = "antoboorox" # Votre pseudo GitHub
    name  = "Proball"    # Votre nom de repository
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}
