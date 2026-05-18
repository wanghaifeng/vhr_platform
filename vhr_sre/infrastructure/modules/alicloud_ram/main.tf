locals {
  env_prefix        = "${var.project_name}-${var.environment}"
  ci_username       = var.ci_user_name != "" ? var.ci_user_name : "${var.project_name}-ci-${var.environment}"
  readonly_username = var.readonly_user_name != "" ? var.readonly_user_name : "${var.project_name}-readonly-${var.environment}"
  admin_role_name   = var.environment_admin_ram_role_name != "" ? var.environment_admin_ram_role_name : "${var.project_name}-admin-${var.environment}"

  default_ci_actions = {
    dev = [
      "vpc:*", "ecs:*", "rds:*", "kvstore:*", "oss:*",
      "cs:*", "cr:*", "nlb:*", "slb:*", "log:*"
    ]
    test = [
      "vpc:*", "ecs:*", "rds:*", "kvstore:*", "oss:*",
      "cs:*", "cr:*", "nlb:*", "slb:*", "log:*"
    ]
    perf = [
      "vpc:*", "ecs:*", "rds:*", "kvstore:*", "oss:*",
      "cs:*", "cr:*", "nlb:*", "slb:*", "log:*"
    ]
    staging = [
      "vpc:Describe*", "vpc:List*",
      "ecs:Describe*", "ecs:List*", "ecs:RunCommand", "ecs:StopInstance",
      "rds:Describe*", "rds:List*",
      "kvstore:Describe*", "kvstore:List*",
      "oss:Get*", "oss:List*", "oss:PutObject",
      "cs:Describe*", "cs:List*",
      "cr:Get*", "cr:List*", "cr:PushRepository",
      "nlb:Describe*", "nlb:List*",
      "log:Get*", "log:List*"
    ]
    prod = [
      "vpc:Describe*", "vpc:List*",
      "ecs:Describe*", "ecs:List*",
      "rds:Describe*", "rds:List*",
      "kvstore:Describe*", "kvstore:List*",
      "oss:Get*", "oss:List*",
      "cs:Describe*", "cs:List*",
      "cr:Get*", "cr:List*",
      "nlb:Describe*", "nlb:List*",
      "log:Get*", "log:List*"
    ]
  }

  default_deny_actions = {
    dev     = ["ram:*", "actiontrail:*", "kms:*"]
    test    = ["ram:*", "actiontrail:*", "kms:*", "ecs:DeleteInstance", "rds:DeleteDBInstance"]
    perf    = ["ram:*", "actiontrail:*", "kms:*", "ecs:DeleteInstance", "rds:DeleteDBInstance"]
    staging = ["ram:*", "actiontrail:*", "kms:*", "ecs:DeleteInstance", "rds:DeleteDBInstance", "cs:DeleteCluster"]
    prod    = ["ram:*", "actiontrail:*", "kms:*", "ecs:*", "rds:*", "kvstore:*", "cs:*", "nlb:*"]
  }

  ci_actions   = length(var.allowed_actions) > 0 ? var.allowed_actions : local.default_ci_actions[var.environment]
  deny_actions = length(var.deny_actions) > 0 ? var.deny_actions : local.default_deny_actions[var.environment]
}

# --- RAM Policy for CI/CD access scoped to this environment ---
resource "alicloud_ram_policy" "ci" {
  count       = var.create_ci_user ? 1 : 0
  policy_name = "${local.env_prefix}-ci-policy"
  description = "CI/CD policy for ${local.env_prefix} environment - scoped to VPC ${var.vpc_id}"
  document = jsonencode({
    Statement = concat(
      [{
        Effect   = "Allow"
        Action   = local.ci_actions
        Resource = ["acs:${var.region}:*:*:*"]
        Condition = {
          StringEquals = {
            "acs:ResourceTag/environment" = [var.environment]
          }
        }
      }],
      [{
        Effect = "Allow"
        Action = local.ci_actions
        Resource = [
          "acs:vpc:${var.region}:*:vpc/${var.vpc_id}",
          "acs:vpc:${var.region}:*:vswitch/*",
          "acs:oss:${var.region}:*:*"
        ]
      }]
    ),
    Version = "1"
  })
  force = true
}

# --- RAM User for CI/CD ---
resource "alicloud_ram_user" "ci" {
  count    = var.create_ci_user ? 1 : 0
  name     = local.ci_username
  comments = "CI/CD user for ${local.env_prefix} environment"
}

resource "alicloud_ram_user_policy_attachment" "ci" {
  count       = var.create_ci_user ? 1 : 0
  user_name   = alicloud_ram_user.ci[0].name
  policy_name = alicloud_ram_policy.ci[0].policy_name
  policy_type = alicloud_ram_policy.ci[0].type
}

# --- RAM AccessKey for CI/CD user ---
resource "alicloud_ram_access_key" "ci" {
  count     = var.create_ci_user ? 1 : 0
  user_name = alicloud_ram_user.ci[0].name
  pgp_key   = ""
}

# --- Read-only Policy ---
resource "alicloud_ram_policy" "readonly" {
  count       = var.create_readonly_user ? 1 : 0
  policy_name = "${local.env_prefix}-readonly-policy"
  description = "Read-only policy for ${local.env_prefix} environment"
  document = jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = [
        "vpc:Describe*", "vpc:List*",
        "ecs:Describe*", "ecs:List*",
        "rds:Describe*", "rds:List*",
        "kvstore:Describe*", "kvstore:List*",
        "oss:Get*", "oss:List*",
        "cs:Describe*", "cs:List*",
        "cr:Get*", "cr:List*",
        "nlb:Describe*", "nlb:List*",
        "log:Get*", "log:List*",
        "ram:Get*", "ram:List*"
      ]
      Resource = ["acs:*:${var.region}:*:*:*"]
      Condition = {
        StringEquals = {
          "acs:ResourceTag/environment" = [var.environment]
        }
      }
    }],
    Version = "1"
  })
  force = true
}

resource "alicloud_ram_user" "readonly" {
  count    = var.create_readonly_user ? 1 : 0
  name     = local.readonly_username
  comments = "Read-only user for ${local.env_prefix} environment"
}

resource "alicloud_ram_user_policy_attachment" "readonly" {
  count       = var.create_readonly_user ? 1 : 0
  user_name   = alicloud_ram_user.readonly[0].name
  policy_name = alicloud_ram_policy.readonly[0].policy_name
  policy_type = alicloud_ram_policy.readonly[0].type
}

# --- Environment Admin RAM Role (for assume-role / temporary elevated access) ---
resource "alicloud_ram_role" "env_admin" {
  name        = local.admin_role_name
  description = "Admin role for ${local.env_prefix} environment - assume for temporary elevated access"
  document = jsonencode({
    Statement = [{
      Effect = "Allow"
      Principal = {
        RAM = ["acs:ram::*:root"]
      }
      Action    = "sts:AssumeRole"
      Condition = {}
    }]
    Version = "1"
  })
  force = true
}

resource "alicloud_ram_policy" "env_admin" {
  policy_name = "${local.env_prefix}-admin-policy"
  description = "Admin policy for ${local.env_prefix} environment - full CRUD scoped to environment tag"
  document = jsonencode({
    Statement = concat(
      [{
        Effect = "Allow"
        Action = [
          "vpc:*", "ecs:*", "rds:*", "kvstore:*", "oss:*",
          "cs:*", "cr:*", "nlb:*", "slb:*", "log:*", "alidns:*"
        ]
        Resource = ["acs:*:${var.region}:*:*:*"]
        Condition = {
          StringEquals = {
            "acs:ResourceTag/environment" = [var.environment]
          }
        }
      }],
      [{
        Effect = "Allow"
        Action = ["vpc:*", "oss:*", "cr:*", "alidns:*"]
        Resource = [
          "acs:vpc:${var.region}:*:vpc/${var.vpc_id}",
          "acs:oss:${var.region}:*:*",
          "acs:cr:${var.region}:*:*",
          "acs:alidns:${var.region}:*:*"
        ]
      }],
      [{
        Effect   = "Deny"
        Action   = local.deny_actions
        Resource = ["*"]
      }]
    ),
    Version = "1"
  })
  force = true
}

resource "alicloud_ram_role_policy_attachment" "env_admin" {
  role_name   = alicloud_ram_role.env_admin.name
  policy_name = alicloud_ram_policy.env_admin.policy_name
  policy_type = alicloud_ram_policy.env_admin.type
}

# --- ACK Worker RAM Role scoped policy ---
resource "alicloud_ram_policy" "ack_worker" {
  count       = var.create_ack_worker_policy ? 1 : 0
  policy_name = "${local.env_prefix}-ack-worker-policy"
  description = "Scoped policy for ACK worker nodes in ${local.env_prefix}"
  document = jsonencode({
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:Describe*", "ecs:List*",
          "vpc:Describe*", "vpc:List*",
          "slb:Describe*", "slb:List*", "slb:SetBackendServers",
          "cr:Get*", "cr:List*", "cr:PullRepository",
          "oss:Get*", "oss:List*", "oss:PutObject",
          "log:PostLogStoreLogs"
        ]
        Resource = ["acs:*:${var.region}:*:*:*"]
      }
    ],
    Version = "1"
  })
  force = true
}

resource "alicloud_ram_role_policy_attachment" "ack_worker" {
  count       = var.create_ack_worker_policy ? 1 : 0
  role_name   = var.ack_worker_ram_role_name
  policy_name = alicloud_ram_policy.ack_worker[0].policy_name
  policy_type = alicloud_ram_policy.ack_worker[0].type
}
