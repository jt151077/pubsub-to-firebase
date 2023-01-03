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


resource "google_project_iam_member" "publisher" {
  depends_on = [
    google_cloudfunctions_function.crusher_function
  ]

  project = local.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${local.project_id}@appspot.gserviceaccount.com"
}

resource "google_storage_bucket_iam_member" "member" {
  depends_on = [
    google_project_service.gcp_services
  ]

  bucket = google_storage_bucket.crusher_function_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${local.project_number}@cloudbuild.gserviceaccount.com"

}

resource "google_project_iam_member" "datastoreUser" {
  depends_on = [
    google_cloudfunctions_function.crusher_function
  ]

  project = local.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${local.project_id}@appspot.gserviceaccount.com"
}

resource "google_service_account" "account" {
  depends_on = [
    google_cloudfunctions_function.crusher_function
  ]

  project      = local.project_id
  account_id   = "gcf-sa"
  display_name = "Test Service Account - used for both the cloud function and eventarc trigger in the test"
}

resource "google_project_iam_member" "invoking" {
  depends_on = [
    google_service_account.account
  ]

  project = local.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.account.email}"
}

resource "google_project_iam_member" "event-receiving" {
  depends_on = [
    google_service_account.account
  ]

  project = local.project_id
  role    = "roles/eventarc.eventReceiver"
  member  = "serviceAccount:${google_service_account.account.email}"
}

resource "google_project_iam_member" "datastoreUser1" {
  depends_on = [
    google_service_account.account
  ]

  project = local.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.account.email}"
}