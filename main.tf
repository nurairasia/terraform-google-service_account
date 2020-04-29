terraform {
  required_version = "0.12.24" # see https://releases.hashicorp.com/terraform/
  experiments      = [variable_validation]
}

provider "google" {
  version = "3.13.0" # see https://github.com/terraform-providers/terraform-provider-google/releases
}

locals {
  full_account_id   = format("%s-%s", var.account_id, var.tf_env)
  full_display_name = format("%s-%s", var.display_name, var.tf_env)
  logging_and_monitoring_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/stackdriver.resourceMetadata.writer"
    # see https://cloud.google.com/monitoring/kubernetes-engine/observing#troubleshooting
  ]
  all_roles                      = toset(concat(local.logging_and_monitoring_roles, var.roles))
  sensitive_roles                = ["roles/owner" /* we want to prevent terraform from granting sensitive roles to any resources */]
  filtered_service_account_roles = setsubtract(local.all_roles, local.sensitive_roles)
}

resource "google_service_account" "service_account" {
  account_id   = local.full_account_id
  display_name = local.full_display_name
  description  = var.description
  depends_on   = [var.module_depends_on]
}

resource "google_project_iam_member" "project_roles" {
  for_each   = local.filtered_service_account_roles
  role       = each.value
  member     = "serviceAccount:${google_service_account.service_account.email}"
  depends_on = [var.module_depends_on]
}
