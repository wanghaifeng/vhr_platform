provider "alicloud" {
  region  = var.region
}

resource "alicloud_log_project" "vhr_log_project" {
  name        = "vhr-log-project"
  description = "Log project for VHR application"
}

resource "alicloud_log_store" "vhr_access_log_store" {
  project              = alicloud_log_project.vhr_log_project.name
  name                 = "vhr-access-logstore"
  retention_period     = 30
  shard_count          = 2
  auto_split           = true
  max_split_shard_count = 60
}

resource "alicloud_log_store" "vhr_error_log_store" {
  project              = alicloud_log_project.vhr_log_project.name
  name                 = "vhr-error-logstore"
  retention_period     = 30
  shard_count          = 2
  auto_split           = true
  max_split_shard_count = 60
}

# Example of a simple monitoring dashboard or alert if needed later.
# This part is highly dependent on the specific monitoring service (e.g., CloudMonitor, Grafana).
# For simplicity, we are just creating the logging infrastructure here.
