/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


resource "random_id" "unique-id" {
  byte_length = 4
}

locals {
  unique_hash           = substr(random_id.unique-id.hex, 0, 8)
  crusher_function_name = "${local.unique_hash}_crusher.zip"
  crusher_function_path = "./crusher/${local.crusher_function_name}"
}

data "archive_file" "crusher_bundle" {
  type        = "zip"
  output_path = local.crusher_function_path

  source {
    content  = file("./crusher/main.py")
    filename = "main.py"
  }

  source {
    content  = file("./crusher/requirements.txt")
    filename = "requirements.txt"
  }
}

resource "google_storage_bucket" "crusher_function_bucket" {
  depends_on = [
    google_project_service.gcp_services
  ]

  project  = local.project_id
  name     = "${local.project_id}_cf"
  location = local.project_default_region
}

resource "google_storage_bucket_object" "crusher_archive" {
  depends_on = [
    google_project_service.gcp_services,
    google_storage_bucket.crusher_function_bucket,
    data.archive_file.crusher_bundle
  ]

  name   = "${data.archive_file.crusher_bundle.output_sha}.zip"
  bucket = google_storage_bucket.crusher_function_bucket.name
  source = local.crusher_function_path
}

resource "google_cloudfunctions_function" "crusher_function" {
  depends_on = [
    google_project_service.gcp_services,
    google_storage_bucket.crusher_function_bucket,
    google_storage_bucket_object.crusher_archive,
    google_pubsub_topic.crusher-topic
  ]

  project = local.project_id
  name    = "crusher_data"
  runtime = "python38"
  region  = local.project_default_region

  available_memory_mb   = 256
  source_archive_bucket = google_storage_bucket.crusher_function_bucket.name
  source_archive_object = google_storage_bucket_object.crusher_archive.name

  max_instances = 3000

  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.crusher-topic.name
  }

  timeout     = 120
  entry_point = "crusher"

  environment_variables = {
    PROJECT_ID = local.project_id
  }
}

/*resource "google_cloudfunctions2_function" "function" {
  depends_on = [
    google_project_service.gcp_services,
    google_storage_bucket.crusher_function_bucket,
    google_storage_bucket_object.crusher_archive,
    google_pubsub_topic.crusher-topic
  ]

  project  = local.project_id
  name     = "crusher-data-2"
  location = local.project_default_region

  build_config {
    runtime     = "python38"
    entry_point = "crusher" # Set the entry point 
    environment_variables = {
      PROJECT_ID = local.project_id
    }
    source {
      storage_source {
        bucket = google_storage_bucket.crusher_function_bucket.name
        object = google_storage_bucket_object.crusher_archive.name
      }
    }
  }

  service_config {
    max_instance_count = 1000
    min_instance_count = 0
    available_memory   = "256Mi"
    timeout_seconds    = 60
    environment_variables = {
      PROJECT_ID = local.project_id
    }
    ingress_settings               = "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.account.email
  }

  event_trigger {
    trigger_region = local.project_default_region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.crusher-topic.id
    retry_policy          = "RETRY_POLICY_DO_NOT_RETRY"
  }
}*/
