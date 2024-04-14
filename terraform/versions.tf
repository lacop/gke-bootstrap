terraform {
    required_version = ">= 1.7"
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "5.24.0"
        }
        helm = {
            source  = "hashicorp/helm"
            version = "2.13.0"
        }
    }
}