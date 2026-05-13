mock_provider "alicloud" {}

run "plan_dev" {
  command = plan

  variables {
    mysql_root_password = "dummy_password"
    redis_password      = "dummy_password"
  }

  module {
    source = "./environments/dev"
  }
}
