terraform {
   backend "oss" {
        bucket  = "vhr-terraform-state-dev"
        prefix  = "infra/terraform.tfstate"
        region  = "cn-beijing"
    }
}
