terraform {
   backend "oss" {
        bucket  = "vhr-terraform-state-prod"
        prefix  = "infra/terraform.tfstate"
        region  = "cn-beijing"
    }
}
