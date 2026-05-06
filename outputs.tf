##############################################################################
# outputs.tf
# Meridian Health — Service Account Infrastructure
#
# Outputs service account emails for consumption by other Terraform modules
# (e.g., workload identity bindings, GKE node pool configs, Cloud Run specs).
##############################################################################

output "service_account_emails" {
  description = "Map of application shortname to service account email address."
  value = {
    for k, v in google_service_account.app :
    k => v.email
  }
}

output "phi_service_account_emails" {
  description = "Service account emails for PHI-bearing applications only."
  value = {
    for k, v in google_service_account.app :
    k => v.email
    if local.applications[k].data_class == "phi"
  }
}

output "non_phi_service_account_emails" {
  description = "Service account emails for non-PHI applications only."
  value = {
    for k, v in google_service_account.app :
    k => v.email
    if local.applications[k].data_class != "phi"
  }
}
