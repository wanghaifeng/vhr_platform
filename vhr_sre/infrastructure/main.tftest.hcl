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

run "plan_test" {
  command = plan

  variables {
    mysql_root_password = "dummy_password"
    redis_password      = "dummy_password"
  }

  module {
    source = "./environments/test"
  }
}

run "plan_perf" {
  command = plan

  variables {
    mysql_root_password = "dummy_password"
    redis_password      = "dummy_password"
  }

  module {
    source = "./environments/perf"
  }
}

run "plan_staging" {
  command = plan

  variables {
    mysql_root_password = "dummy_password"
    redis_password      = "dummy_password"
  }

  module {
    source = "./environments/staging"
  }
}

run "plan_prod" {
  command = plan

  variables {
    mysql_root_password = "dummy_password"
    redis_password      = "dummy_password"
  }

  module {
    source = "./environments/prod"
  }
}
