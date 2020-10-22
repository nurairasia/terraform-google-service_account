output "email" {
  description = "The fully qualified email address of the created ServiceAccount."
  value       = google_service_account.service_account.email
}
