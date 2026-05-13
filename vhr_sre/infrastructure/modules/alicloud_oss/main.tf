resource "alicloud_oss_bucket" "app_storage" {
  bucket = "${var.environment}-vhr-app-storage"
  acl    = "private"
  storage_class = "Standard"
  force_destroy = true # For easy cleanup during development

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE", "HEAD"]
    allowed_origins = var.oss_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  lifecycle_rule {
    enabled = true
    id      = "delete_old_files"
    prefix  = "logs/"
    expiration {
      days = 30
    }
  }

  tags = {
    environment = var.environment
    project     = "vhr"
    role        = "app-storage"
  }
}
