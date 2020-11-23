
####################################################
# Locals
####################################################

locals {

  account_id  = data.aws_caller_identity.current.account_id
  
  #======================
  # CodeBuild - General
  #======================
  common_name    = "hmpps-nextcloud-packer-builder"
  build_timeout  = "45"
  queued_timeout = "30"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn_packer_ami_builder"]

  region          = var.region
  tags            = var.tags

  #======================
  # CodeBuild - Logs
  #======================

  group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
  stream_name = "hmpps-nextcloud-packer-ami-bake"

  #======================
  # CodeBuild - General
  #======================
  build_artifacts = {
    type                   = "NO_ARTIFACTS"
  }

  #======================
  # CodeBuild - Source
  #======================
  build_source = {
    type                = "GITHUB"
    location           = "https://github.com/ministryofjustice/hmpps-nextcloud-packer.git"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    git_submodules_config = {
      fetch_submodules = false
    }
    buildspec = "buildspec_nextcloud-centos.yml"
  }

  #======================
  # CodeBuild - Environment
  #======================
  build_environment_spec = {
    compute_type    = "BUILD_GENERAL1_SMALL"
    images = {
      packer    = data.terraform_remote_state.common.outputs.codebuild_info["packerbuilder_image"]
    }
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = true
    environment_variables = {
      "ARTIFACT_BUCKET" = "tf-eu-west-2-hmpps-eng-dev-config-s3bucket"
      "ZAIZI_BUCKET"    = "tf-eu-west-2-hmpps-eng-dev-artefacts-s3bucket"
      "AWS_REGION"      = var.region
    }    

  }

  #=======================
  # CodeBuild - VPC Config
  #=======================
  vpc_config = {
    vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
    
    subnet_ids = [
      data.terraform_remote_state.vpc.outputs.private-subnet-az1,
      data.terraform_remote_state.vpc.outputs.private-subnet-az2,
      data.terraform_remote_state.vpc.outputs.private-subnet-az3,
    ]

    security_group_ids = [
      data.terraform_remote_state.common.outputs.codebuild_info["packerbuilder_client_security_group"],
      data.terraform_remote_state.common.outputs.codebuild_info["packerbuilder_instance_security_group"],
    ]
  }

  
  project_names = {
    ami_build       = "hmpps-nextcloud-packer-ami-build"
  }
    
}

