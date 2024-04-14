# GKE bootstrap

Automation to create and configure a basic, cheap GKE cluster.

Based on the great [How to Run a GKE Cluster on the Cheap](https://github.com/murphye/cheap-gke-cluster/), updated, simplified and customized for my needs.

## Dev environment

Requires `nix` and flakes enabled. Then just `nix develop --no-write-lock-file` to enter the dev shell.

## GKE initial bootstrap

Copy `terraform/terraform.tfvars.template` to `terraform/terraform.tfvars` and edit as required, then run the following.

```shell
# Configure gcloud CLI
gcloud config set project <id>
gcloud config set compute/region europe-west1
gcloud config set compute/zone europe-west1-b

# Enable GKE.
gcloud services enable container.googleapis.com

# Terraform setup.
cd terraform/
terraform init

# Update loop - repeat these two after any changes.
terraform plan
# Review the output and apply.
terraform apply

# Setup kubectl and check that it works.
gcloud container clusters get-credentials <cluster-name>
kubectl get nodes
```

## Command reference

Find external cluster IP: `gcloud compute addressed list`.
