output "oss_bucket_name" {
  description = "The name of the OSS bucket"
  value       = alicloud_oss_bucket.app_storage.bucket
}

output "oss_bucket_endpoint" {
  description = "The endpoint of the OSS bucket"
  value       = alicloud_oss_bucket.app_storage.extranet_endpoint
}
