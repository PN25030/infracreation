# Configure the Google Cloud provider
provider "google" {
  project = "<YOUR_PROJECT_ID>"
  region  = "us-central1"
}

# Enable necessary APIs
resource "google_project_service" "dataflow_api" {
  service = "dataflow.googleapis.com"
}

resource "google_project_service" "bigquery_api" {
  service = "bigquery.googleapis.com"
}

resource "google_project_service" "storage_api" {
  service = "storage.googleapis.com"
}

# Create a service account for Dataflow
resource "google_service_account" "dataflow_service_account" {
  account_id   = "dataflow-service-account"
  display_name = "Dataflow Service Account"
}

# Assign required roles to the service account
resource "google_project_iam_member" "dataflow_role" {
  project = "<YOUR_PROJECT_ID>"
  role    = "roles/dataflow.admin"
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
}

resource "google_project_iam_member" "storage_role" {
  project = "<YOUR_PROJECT_ID>"
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
}

resource "google_project_iam_member" "bigquery_role" {
  project = "<YOUR_PROJECT_ID>"
  role    = "roles/bigquery.admin"
  member  = "serviceAccount:${google_service_account.dataflow_service_account.email}"
}

# Create a default VPC network
resource "google_compute_network" "default_network" {
  name                    = "default-vpc"
  auto_create_subnetworks = true
}

# Create a Cloud Storage bucket
resource "google_storage_bucket" "dataflow_bucket" {
  name     = "dataflow-job-bucket"
  location = "US"
  force_destroy = true
}

# Create a BigQuery dataset
resource "google_bigquery_dataset" "dataflow_dataset" {
  dataset_id = "dataflow_dataset"
  location   = "US"
}

# Create a BigQuery table
resource "google_bigquery_table" "dataflow_table" {
  dataset_id = google_bigquery_dataset.dataflow_dataset.dataset_id
  table_id   = "dataflow_table"

  schema = <<EOF
[
  {
    "name": "id",
    "type": "STRING",
    "mode": "REQUIRED"
  },
  {
    "name": "value",
    "type": "STRING",
    "mode": "NULLABLE"
  }
]
EOF
}
