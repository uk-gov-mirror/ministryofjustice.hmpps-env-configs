
####################################################
# Locals
####################################################

locals {

  account_id  = data.aws_caller_identity.current.account_id
  
  ecr-registry = "895523100917.dkr.ecr.eu-west-2.amazonaws.com"

  
  #======================
  # CodeBuild - General
  #======================
  common_name    = "hmpps-delius-dss-offloc-docker"
  build_timeout  = "120"
  queued_timeout = "30"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn_docker_image_builder"]

  region          = var.region
  tags            = var.tags

  #======================
  # CodeBuild - Logs
  #======================

  group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
  stream_name = "hmpps-delius-dss-offloc-docker"

  #======================
  # CodeBuild - General
  #======================
  build_artifacts = {
    type = "NO_ARTIFACTS"
  }

  #======================
  # CodeBuild - Source
  #======================
  build_source = {
    type                = "GITHUB"
    location           = "https://github.com/ministryofjustice/hmpps-delius-dss-offloc-docker.git"
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    git_submodules_config = {
      fetch_submodules = false
    }
    buildspec = "buildspec.yml"
  }

  #======================
  # CodeBuild - Environment
  #======================
  build_environment_spec = {
    compute_type    = "BUILD_GENERAL1_MEDIUM"  # =https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
   images = {
      amazonlinux2_v3_0    = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    }
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = local.build_environment_spec.privileged_mode
    
    environment_variables = [
      {
        key="ARTIFACT_BUCKET"
        value = "tf-eu-west-2-hmpps-eng-dev-config-s3bucket"
      },
      {
        key="ZAIZI_BUCKET"
        value = "tf-eu-west-2-hmpps-eng-dev-artefacts-s3bucket"
      },
      {
        key="AWS_REGION"
        value = var.region
      },
      {
        key="REGISTRY"
        value = local.ecr-registry
      },
      { 
        key="DSS_VERSION"
        value = "3.0"
      }
    ]

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
    
}

