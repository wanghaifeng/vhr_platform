terraform {
   backend "oss" {
        bucket  = "vhr-terraform-state-perf"
        prefix  = "infra/terraform.tfstate"
        region  = "cn-beijing"
    }
}
