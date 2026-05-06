##############################################################################
# variables.tf
# Meridian Health — Service Account Infrastructure
# Shared input variables for service account and IAM binding modules.
##############################################################################

variable "prod_project_id" {
  description = "GCP project ID for the production environment."
  type        = string
  default     = "meridian-health-prod"
}

variable "nonprod_project_id" {
  description = "GCP project ID for the non-production environment (dev, test, staging)."
  type        = string
  default     = "meridian-health-nonprod"
}

variable "org_domain" {
  description = "GCP organization domain used to construct service account email addresses."
  type        = string
  default     = "meridianhealth.org"
}

variable "region" {
  description = "Default GCP region."
  type        = string
  default     = "us-central1"
}

variable "phi_gcs_buckets" {
  description = "Map of PHI-classified GCS buckets. Key is a logical name; value is the bucket name."
  type        = map(string)
  default = {
    ehr_primary        = "mh-phi-ehr-primary"
    ehr_archive        = "mh-phi-ehr-archive"
    imaging_dicom      = "mh-imaging-dicom-prod"
    clinical_docs      = "mh-clinical-docs-prod"
    ehr_exports        = "mh-ehr-exports-prod"
    lab_results        = "mh-phi-lab-results"
    pharmacy_records   = "mh-phi-pharmacy-records"
  }
}

variable "phi_cloudsql_instances" {
  description = "Map of PHI-classified Cloud SQL instances. Key is a logical name; value is the instance name."
  type        = map(string)
  default = {
    ehr_primary        = "mh-ehr-primary-prod"
    ehr_readonly       = "mh-ehr-readonly-prod"
    clinical_notes     = "mh-clinical-notes-prod"
    lab_systems        = "mh-lab-systems-prod"
    pharmacy           = "mh-pharmacy-prod"
    care_coordination  = "mh-clinical-care-coord-prod"
    medication_admin   = "mh-clinical-med-admin-prod"
    radiology          = "mh-clinical-radiology-prod"
  }
}

variable "phi_bigquery_datasets" {
  description = "Map of PHI-classified BigQuery datasets. Key is a logical name; value is the dataset ID."
  type        = map(string)
  default = {
    phi_raw      = "phi_data"
    clinical     = "clinical_data"
    ehr_analytics = "ehr_analytics"
  }
}

variable "phi_pubsub_topics" {
  description = "Map of PHI-classified Pub/Sub topics. Key is a logical name; value is the topic name."
  type        = map(string)
  default = {
    adt_events           = "mh-phi-adt-events"
    fhir_events          = "mh-phi-fhir-events"
    clinical_events_ehr  = "mh-clinical-events-ehr"
    device_telemetry     = "mh-phi-device-telemetry"
  }
}

variable "internal_gcs_buckets" {
  description = "Map of internal (non-PHI) GCS buckets."
  type        = map(string)
  default = {
    analytics_staging  = "mh-analytics-staging"
    reporting_output   = "mh-internal-reporting"
    etl_staging        = "mh-internal-etl-staging"
    audit_logs         = "mh-internal-audit-logs"
    document_store     = "mh-internal-documents"
  }
}

variable "internal_pubsub_topics" {
  description = "Map of internal (non-PHI) Pub/Sub topics."
  type        = map(string)
  default = {
    scheduling_events   = "mh-scheduling-events"
    notification_alerts = "mh-notification-alerts"
    billing_events      = "mh-billing-events"
    supply_events       = "mh-supply-chain-events"
    hr_events           = "mh-hr-events"
    audit_events        = "mh-audit-events"
  }
}

variable "internal_pubsub_subscriptions" {
  description = "Map of internal Pub/Sub subscriptions."
  type        = map(string)
  default = {
    notification_sub   = "mh-notification-alerts-sub"
    audit_sub          = "mh-audit-events-sub"
    analytics_sub      = "mh-analytics-ingest-sub"
    data_integration_sub = "mh-data-integration-sub"
  }
}
