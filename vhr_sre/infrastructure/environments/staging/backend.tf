terraform {
   backend "oss" {
        bucket  = "vhr-terraform-state-staging"
        prefix  = "infra/terraform.tfstate"
        region  = "cn-beijing"
    }
}
