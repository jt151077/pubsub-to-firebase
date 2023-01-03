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

resource "google_firebase_project" "firebase" {
  depends_on = [
    google_project_service.gcp_services
  ]

  provider = google-beta
  project  = local.project_id
}

resource "google_app_engine_application" "firestore" {
  depends_on    = [google_firebase_project.firebase]
  provider      = google-beta
  project       = local.project_id
  location_id   = "europe-west"
  database_type = "CLOUD_FIRESTORE"
}

resource "google_firestore_document" "document" {
  depends_on = [google_firebase_project.firebase]

  project     = local.project_id
  collection  = "crusher"
  document_id = "status"
  fields      = <<EOT
  {
      "value":{
        "integerValue": "0"
      },
      "pant": {
        "integerValue": "1000000"
      }
  }
  EOT
}

resource "google_firebaserules_ruleset" "later" {
  provider = google-beta

  source {
    files {
      content = "service cloud.firestore {match /databases/{database}/documents { match /{document=**} { allow read, write: if request.time < timestamp.date(2023, 3, 20); } } }"
      name    = "firestore.rules"
    }
  }

  project = local.project_id
}

resource "google_firebaserules_release" "primary" {
  provider     = google-beta
  name         = "release"
  ruleset_name = "projects/${local.project_id}/rulesets/${google_firebaserules_ruleset.later.name}"
  project      = local.project_id
}

resource "google_firebase_web_app" "webpubsub" {
  depends_on = [google_firebase_project.firebase]

  provider        = google-beta
  project         = local.project_id
  display_name    = "webpubsub"
  deletion_policy = "DELETE"
}

data "google_firebase_web_app_config" "webpubsub" {
  provider   = google-beta
  project    = local.project_id
  web_app_id = google_firebase_web_app.webpubsub.app_id
}

output "name" {
  value = jsonencode({
    appId             = google_firebase_web_app.webpubsub.app_id
    apiKey            = data.google_firebase_web_app_config.webpubsub.api_key
    authDomain        = data.google_firebase_web_app_config.webpubsub.auth_domain
    databaseURL       = lookup(data.google_firebase_web_app_config.webpubsub, "database_url", "")
    storageBucket     = lookup(data.google_firebase_web_app_config.webpubsub, "storage_bucket", "")
    messagingSenderId = lookup(data.google_firebase_web_app_config.webpubsub, "messaging_sender_id", "")
    measurementId     = lookup(data.google_firebase_web_app_config.webpubsub, "measurement_id", "")
  })
}
