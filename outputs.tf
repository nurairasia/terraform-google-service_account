output "email" {
  description = "The fully qualified email address of the created ServiceAccount."
  value       = google_service_account.service_account.email
}

output "roles" {
  description = "All roles (except sensitive roles filtered by the module) that are attached to this ServiceAccount."
  value       = tolist(local.filtered_roles)
}
