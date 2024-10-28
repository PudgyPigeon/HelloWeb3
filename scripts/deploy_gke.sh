#!/bin/bash

export TF_VAR_project_id="helloweb3-439906"
export TF_VAR_region="us-central1"
export TF_VAR_bucket="helloweb3-terraform-bucket"
export TF_VAR_gke_cluster_name="gke-cluster-1"
export TF_VAR_grafana_admin_user="admin"
export TF_VAR_grafana_admin_password="adminPassword"
export TF_VAR_polygon_api_key=

cd ./terraform

terraform init -backend-config="bucket=${TF_VAR_bucket}" -backend-config="prefix=terraform/state"

terraform plan -out=tfplan

# Check if the terraform plan command was successful
if [ $? -eq 0 ]; then
  echo "Terraform plan succeeded. Applying the plan..."
  terraform apply -auto-approve tfplan
else
  echo "Terraform plan failed. Exiting..."
  exit 1
fi