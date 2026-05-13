terraform {
   backend "oss" {
        bucket  = "vhr-terraform-state-test"
        prefix  = "infra/terraform.tfstate"
        region  = "cn-beijing"
    }
}
