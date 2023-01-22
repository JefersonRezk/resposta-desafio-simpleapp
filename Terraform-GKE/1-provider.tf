# https://registry.terraform.io/providers/hashicorp/google/latest/docs
provider "google" {
    project = "desafio"
    region = "us-central1"
}

# http://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket = "jefersonrezk-tf-state-staging"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "~> 4.0"
    }
  }
}