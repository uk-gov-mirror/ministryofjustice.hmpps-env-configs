# common
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "aws-migration-pipelines/common/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "base" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "aws-migration-pipelines/mis/base/terraform.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "approvals" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket_name
    key    = "aws-migration-pipelines/operations/pipeline_approvals/terraform.tfstate"
    region = var.region
  }
}

#Dev HA Count
data "aws_ssm_parameter" "dev_mis_db_ha_count" {
  name = "/high/availability/count/mis/mis-db/delius-mis-dev"
}

data "aws_ssm_parameter" "dev_misboe_db_ha_count" {
  name = "/high/availability/count/mis/misboe-db/delius-mis-dev"
}

data "aws_ssm_parameter" "dev_misdsd_db_ha_count" {
  name = "/high/availability/count/mis/misdsd-db/delius-mis-dev"
}


#Auto-test HA Count
data "aws_ssm_parameter" "autotest_mis_db_ha_count" {
  name = "/high/availability/count/mis/mis-db/delius-auto-test"
}

data "aws_ssm_parameter" "autotest_misboe_db_ha_count" {
  name = "/high/availability/count/mis/misboe-db/delius-auto-test"
}

data "aws_ssm_parameter" "autotest_misdsd_db_ha_count" {
  name = "/high/availability/count/mis/misdsd-db/delius-auto-test"
}

#stage HA Count
data "aws_ssm_parameter" "stage_mis_db_ha_count" {
  name = "/high/availability/count/mis/mis-db/delius-stage"
}

data "aws_ssm_parameter" "stage_misboe_db_ha_count" {
  name = "/high/availability/count/mis/misboe-db/delius-stage"
}

data "aws_ssm_parameter" "stage_misdsd_db_ha_count" {
  name = "/high/availability/count/mis/misdsd-db/delius-stage"
}

#preprod HA Count
data "aws_ssm_parameter" "preprod_mis_db_ha_count" {
  name = "/high/availability/count/mis/mis-db/delius-pre-prod"
}

data "aws_ssm_parameter" "preprod_misboe_db_ha_count" {
  name = "/high/availability/count/mis/misboe-db/delius-pre-prod"
}

data "aws_ssm_parameter" "preprod_misdsd_db_ha_count" {
  name = "/high/availability/count/mis/misdsd-db/delius-pre-prod"
}

#prod HA Count
data "aws_ssm_parameter" "prod_mis_db_ha_count" {
  name = "/high/availability/count/mis/mis-db/delius-prod"
}

data "aws_ssm_parameter" "prod_misboe_db_ha_count" {
  name = "/high/availability/count/mis/misboe-db/delius-prod"
}

data "aws_ssm_parameter" "prod_misdsd_db_ha_count" {
  name = "/high/availability/count/mis/misdsd-db/delius-prod"
}
