terraform {
  required_version = ">= 0.13.1" # see https://releases.hashicorp.com/terraform/
}

locals {
  full_account_id   = format("%s-%s", var.name, var.name_suffix)
  full_display_name = format("%s %s", var.display_name, var.name_suffix)
  roles             = toset(var.roles)
  sensitive_roles   = ["roles/owner" /* we want to prevent terraform from granting sensitive roles to any resources */]
  filtered_roles    = setsubtract(local.roles, local.sensitive_roles)
}

resource "google_service_account" "service_account" {
  account_id   = local.full_account_id
  display_name = local.full_display_name
  description  = var.description
}

resource "google_project_iam_member" "project_roles" {
  for_each = local.filtered_roles
  role     = each.value
  member   = "serviceAccount:${google_service_account.service_account.email}"
}
