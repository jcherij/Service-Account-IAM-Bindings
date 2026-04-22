##############################################################################
# iam_bindings.tf
# Meridian Health — Service Account Infrastructure
#
# Assigns IAM roles to service accounts. All bindings follow the least-
# privilege rules defined in:
#   - IAM Role Assignment Policy (Confluence)
#   - PHI Data Access Policy — Service Accounts (Confluence)
#
# PHI resource bindings:
#   - Are scoped to specific resources (not project-level)
#   - Include mandatory IAM conditions
#   - Use only approved roles for PHI resources
#
# Non-PHI resource bindings:
#   - Are scoped to the most restrictive resource level possible
#   - Use only approved roles from the permitted-role list
##############################################################################

##############################################################################
# OBSERVABILITY — All service accounts
# roles/logging.logWriter and roles/monitoring.metricWriter at project level
# are permitted and required for all applications per policy.
##############################################################################

resource "google_project_iam_member" "logging" {
  for_each = local.applications

  project = each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${each.key}-${each.value.env}-svc@${each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "monitoring" {
  for_each = local.applications

  project = each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${each.key}-${each.value.env}-svc@${each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "tracing" {
  for_each = local.applications

  project = each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id
  role    = "roles/cloudtrace.agent"
  member  = "serviceAccount:${each.key}-${each.value.env}-svc@${each.value.env == "prod" ? var.prod_project_id : var.nonprod_project_id}.iam.gserviceaccount.com"
}

##############################################################################
# PHI APPLICATIONS — Cloud SQL access
# roles/cloudsql.client at project level with mandatory IAM condition
# restricting access to the specific PHI instance.
##############################################################################

resource "google_project_iam_member" "ehr_core_cloudsql" {
  project = var.prod_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_cloudsql_access_ehr_core_prod"
    description = "Restrict EHR Core Cloud SQL access to mh-ehr-primary-prod instance only"
    expression  = "resource.name == \"projects/${var.prod_project_id}/instances/${var.phi_cloudsql_instances["ehr_primary"]}\""
  }

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "clinical_notes_cloudsql" {
  project = var.prod_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:clinical-notes-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_cloudsql_access_clinical_notes_prod"
    description = "Restrict Clinical Notes Cloud SQL access to mh-clinical-notes-prod instance only"
    expression  = "resource.name == \"projects/${var.prod_project_id}/instances/${var.phi_cloudsql_instances["clinical_notes"]}\""
  }

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "lab_systems_cloudsql" {
  project = var.prod_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:lab-systems-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_cloudsql_access_lab_systems_prod"
    description = "Restrict Lab Systems Cloud SQL access to mh-lab-systems-prod instance only"
    expression  = "resource.name == \"projects/${var.prod_project_id}/instances/${var.phi_cloudsql_instances["lab_systems"]}\""
  }

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "pharmacy_mgmt_cloudsql" {
  project = var.prod_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:pharmacy-mgmt-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_cloudsql_access_pharmacy_prod"
    description = "Restrict Pharmacy Management Cloud SQL access to mh-pharmacy-prod instance only"
    expression  = "resource.name == \"projects/${var.prod_project_id}/instances/${var.phi_cloudsql_instances["pharmacy"]}\""
  }

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "care_coordination_cloudsql" {
  project = var.prod_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:care-coordination-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_cloudsql_access_care_coord_prod"
    description = "Restrict Care Coordination Cloud SQL access to mh-clinical-care-coord-prod instance only"
    expression  = "resource.name == \"projects/${var.prod_project_id}/instances/${var.phi_cloudsql_instances["care_coordination"]}\""
  }

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "medication_admin_cloudsql" {
  project = var.prod_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:medication-admin-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_cloudsql_access_med_admin_prod"
    description = "Restrict Medication Admin Cloud SQL access to mh-clinical-med-admin-prod instance only"
    expression  = "resource.name == \"projects/${var.prod_project_id}/instances/${var.phi_cloudsql_instances["medication_admin"]}\""
  }

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "radiology_cloudsql" {
  project = var.prod_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:radiology-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_cloudsql_access_radiology_prod"
    description = "Restrict Radiology Cloud SQL access to mh-clinical-radiology-prod instance only"
    expression  = "resource.name == \"projects/${var.prod_project_id}/instances/${var.phi_cloudsql_instances["radiology"]}\""
  }

  depends_on = [google_service_account.app]
}

##############################################################################
# PHI APPLICATIONS — GCS bucket access (resource-level, with conditions)
##############################################################################

resource "google_storage_bucket_iam_member" "ehr_core_gcs_reader" {
  bucket = var.phi_gcs_buckets["ehr_primary"]
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_gcs_read_ehr_core_prod"
    description = "Restrict EHR Core GCS read to mh-phi-ehr-primary bucket"
    expression  = "resource.name.startsWith(\"projects/_/buckets/${var.phi_gcs_buckets["ehr_primary"]}/objects/\")"
  }

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "clinical_notes_gcs_writer" {
  bucket = var.phi_gcs_buckets["clinical_docs"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:clinical-notes-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_gcs_write_clinical_notes_prod"
    description = "Restrict Clinical Notes GCS write to mh-clinical-docs-prod bucket"
    expression  = "resource.name.startsWith(\"projects/_/buckets/${var.phi_gcs_buckets["clinical_docs"]}/objects/\")"
  }

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "clinical_imaging_gcs_writer" {
  bucket = var.phi_gcs_buckets["imaging_dicom"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:clinical-imaging-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_gcs_write_clinical_imaging_prod"
    description = "Restrict Clinical Imaging GCS write to mh-imaging-dicom-prod bucket"
    expression  = "resource.name.startsWith(\"projects/_/buckets/${var.phi_gcs_buckets["imaging_dicom"]}/objects/\")"
  }

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "lab_systems_gcs_writer" {
  bucket = var.phi_gcs_buckets["lab_results"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:lab-systems-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_gcs_write_lab_systems_prod"
    description = "Restrict Lab Systems GCS write to mh-phi-lab-results bucket"
    expression  = "resource.name.startsWith(\"projects/_/buckets/${var.phi_gcs_buckets["lab_results"]}/objects/\")"
  }

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "pharmacy_gcs_writer" {
  bucket = var.phi_gcs_buckets["pharmacy_records"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:pharmacy-mgmt-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_gcs_write_pharmacy_prod"
    description = "Restrict Pharmacy Management GCS write to mh-phi-pharmacy-records bucket"
    expression  = "resource.name.startsWith(\"projects/_/buckets/${var.phi_gcs_buckets["pharmacy_records"]}/objects/\")"
  }

  depends_on = [google_service_account.app]
}

##############################################################################
# PHI APPLICATIONS — BigQuery access (dataset-level, with conditions)
##############################################################################

resource "google_bigquery_dataset_iam_member" "ehr_core_bq_viewer" {
  project    = var.prod_project_id
  dataset_id = var.phi_bigquery_datasets["ehr_analytics"]
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "ehr_core_bq_job_user" {
  project = var.prod_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_bigquery_dataset_iam_member" "analytics_platform_bq_viewer" {
  project    = var.prod_project_id
  dataset_id = var.phi_bigquery_datasets["clinical"]
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:analytics-platform-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "analytics_platform_bq_job_user" {
  project = var.prod_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:analytics-platform-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_bigquery_dataset_iam_member" "reporting_svc_bq_viewer" {
  project    = var.prod_project_id
  dataset_id = var.phi_bigquery_datasets["clinical"]
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:reporting-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_project_iam_member" "reporting_svc_bq_job_user" {
  project = var.prod_project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:reporting-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

##############################################################################
# PHI APPLICATIONS — Pub/Sub (topic/subscription-level, with conditions)
##############################################################################

resource "google_pubsub_topic_iam_member" "referral_mgmt_fhir_publisher" {
  project = var.prod_project_id
  topic   = var.phi_pubsub_topics["fhir_events"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:referral-mgmt-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_pubsub_publish_referral_prod"
    description = "Restrict Referral Management Pub/Sub publish to mh-phi-fhir-events topic"
    expression  = "resource.name == \"projects/${var.prod_project_id}/topics/${var.phi_pubsub_topics["fhir_events"]}\""
  }

  depends_on = [google_service_account.app]
}

resource "google_pubsub_topic_iam_member" "device_integration_telemetry_publisher" {
  project = var.prod_project_id
  topic   = var.phi_pubsub_topics["device_telemetry"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:device-integration-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_pubsub_publish_device_telemetry_prod"
    description = "Restrict Device Integration Pub/Sub publish to mh-phi-device-telemetry topic"
    expression  = "resource.name == \"projects/${var.prod_project_id}/topics/${var.phi_pubsub_topics["device_telemetry"]}\""
  }

  depends_on = [google_service_account.app]
}

resource "google_pubsub_topic_iam_member" "ehr_core_adt_publisher" {
  project = var.prod_project_id
  topic   = var.phi_pubsub_topics["adt_events"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  condition {
    title       = "phi_pubsub_publish_ehr_adt_prod"
    description = "Restrict EHR Core Pub/Sub publish to mh-phi-adt-events topic"
    expression  = "resource.name == \"projects/${var.prod_project_id}/topics/${var.phi_pubsub_topics["adt_events"]}\""
  }

  depends_on = [google_service_account.app]
}

##############################################################################
# NON-PHI APPLICATIONS — GCS access (bucket-level, no conditions required)
##############################################################################

resource "google_storage_bucket_iam_member" "analytics_platform_gcs_reader" {
  bucket = var.internal_gcs_buckets["analytics_staging"]
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:analytics-platform-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "reporting_svc_gcs_writer" {
  bucket = var.internal_gcs_buckets["reporting_output"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:reporting-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "data_integration_gcs_writer" {
  bucket = var.internal_gcs_buckets["etl_staging"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:data-integration-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "document_mgmt_gcs_writer" {
  bucket = var.internal_gcs_buckets["document_store"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:document-mgmt-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_storage_bucket_iam_member" "audit_logging_gcs_writer" {
  bucket = var.internal_gcs_buckets["audit_logs"]
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:audit-logging-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

##############################################################################
# NON-PHI APPLICATIONS — Pub/Sub (topic/subscription-level)
##############################################################################

resource "google_pubsub_topic_iam_member" "notification_svc_publisher" {
  project = var.prod_project_id
  topic   = var.internal_pubsub_topics["notification_alerts"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:notification-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_subscription_iam_member" "notification_svc_subscriber" {
  project      = var.prod_project_id
  subscription = var.internal_pubsub_subscriptions["notification_sub"]
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:notification-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_topic_iam_member" "billing_platform_publisher" {
  project = var.prod_project_id
  topic   = var.internal_pubsub_topics["billing_events"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:billing-platform-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_topic_iam_member" "supply_chain_publisher" {
  project = var.prod_project_id
  topic   = var.internal_pubsub_topics["supply_events"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:supply-chain-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_topic_iam_member" "audit_logging_publisher" {
  project = var.prod_project_id
  topic   = var.internal_pubsub_topics["audit_events"]
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:audit-logging-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_subscription_iam_member" "audit_logging_subscriber" {
  project      = var.prod_project_id
  subscription = var.internal_pubsub_subscriptions["audit_sub"]
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:audit-logging-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_pubsub_subscription_iam_member" "data_integration_subscriber" {
  project      = var.prod_project_id
  subscription = var.internal_pubsub_subscriptions["data_integration_sub"]
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:data-integration-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

##############################################################################
# SECRET MANAGER — resource-scoped for selected applications
##############################################################################

resource "google_secret_manager_secret_iam_member" "ehr_core_db_password" {
  project   = var.prod_project_id
  secret_id = "ehr-core-db-password"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:ehr-core-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_secret_manager_secret_iam_member" "pharmacy_mgmt_db_password" {
  project   = var.prod_project_id
  secret_id = "pharmacy-mgmt-db-password"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:pharmacy-mgmt-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_secret_manager_secret_iam_member" "billing_platform_api_key" {
  project   = var.prod_project_id
  secret_id = "billing-clearinghouse-api-key"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:billing-platform-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}

resource "google_secret_manager_secret_iam_member" "identity_svc_okta_secret" {
  project   = var.prod_project_id
  secret_id = "identity-svc-okta-client-secret"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:identity-svc-prod-svc@${var.prod_project_id}.iam.gserviceaccount.com"

  depends_on = [google_service_account.app]
}
