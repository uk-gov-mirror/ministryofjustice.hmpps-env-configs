
####################################################
# Locals
####################################################

locals {

   account_id  = data.aws_caller_identity.current.account_id

   ecr-registry = "895523100917.dkr.ecr.eu-west-2.amazonaws.com"

  #=====================================
  # CodePipeline - Linux AMI Projects
  #=====================================
  sourcecode_action_name = "clone-github-repository"

  artifact_store = {
    location = "tf-eu-west-2-hmpps-eng-dev-artefacts-s3bucket"
    type     = "S3"
  }

  codepipeline_dockerimagebuilder_role = data.terraform_remote_state.common.outputs.packerbuilder_info["iam_role_arn_codepipeline"]

  code_stage = {
      action  = {
        name             = "Code"
        category         = "Source"
        owner            = "ThirdParty"
        provider         = "GitHub"
        version          = "1"
        output_artifacts = ["github_source"]
        namespace        = "SourceVariables"
        configuration = {
          Owner                = "ministryofjustice"
          Repo                 = "hmpps-engineering-tools"
          Branch               = "master"
          PollForSourceChanges = true
        }
      }
  }



codebuild_project_names_stage_1_docker = {
    "base"                     = "${local.common_name}-base"
    "nginx"                    = "${local.common_name}-nginx"
    "base-miniconda"           = "${local.common_name}-base-miniconda"
    "ansible-builder-python-3" = "${local.common_name}-ansible-builder-python-3"
  }

  codebuild_project_names_stage_2_docker = {
    "ansible-builder"           = "${local.common_name}-ansible-builder"
    "ansible-builder-2-7"       = "${local.common_name}-ansible-builder-2-7"
    "terraform-builder-0-11-14" = "${local.common_name}-terraform-builder-0-11-14"
    "terraform-builder-0-12"    = "${local.common_name}-terraform-builder-0-12"
    "jenkins"                   = "${local.common_name}-jenkins"
    "base-java"                 = "${local.common_name}-base-java"
    "base-openrc"               = "${local.common_name}-base-openrc"
    "oraclejdk-builder"         = "${local.common_name}-oraclejdk-builder"
    "base-psql"                 = "${local.common_name}-base-psql"
    "base-mysql"                = "${local.common_name}-base-mysql"
    "docker-cli"                = "${local.common_name}-docker-cli"
  }

  codebuild_project_names_stage_3_docker = {
    "packer-builder"         = "${local.common_name}-packer-builder"
    "terraform-builder-lite" = "${local.common_name}-terraform-builder-lite"
  }

   codebuild_project_names_stage_4_docker = {
    "nginx-router"         = "${local.common_name}-nginx-router"
  }

  codebuild_project_names_stage_5_docker = {
    "base-java-openrc" = "${local.common_name}-base-java-openrc"
    "gatling"          = "${local.common_name}-gatling"
    "gatling-v3"       = "${local.common_name}-gatling-v3"
    "chaosmonkey"      = "${local.common_name}-chaosmonkey"
  }

  codebuild_project_names_stage_6_docker = {
    "logstash"        = "${local.common_name}-logstash"
    "elasticsearch"   = "${local.common_name}-elasticsearch"
    "elasticsearch-2" = "${local.common_name}-elasticsearch-2"
    "elasticsearch-5" = "${local.common_name}-elasticsearch-5"
    "kibana"          = "${local.common_name}-kibana"
  }

  codebuild_project_names_stage_7_docker = {
    "openvpn"               = "${local.common_name}-openvpn"
    "elasticsearch-manager" = "${local.common_name}-elasticsearch-manager"
    "kibana-5"              = "${local.common_name}-kibana-5"
    "aws-nuke"              = "${local.common_name}-aws-nuke"
  }

  codebuild_project_names_stage_8_docker = {
    "nginx-non-confd"   = "${local.common_name}-nginx-non-confd"
    "testing-container" = "${local.common_name}-testing-container"
  }

  codebuild_project_names_all_docker = merge(
    local.codebuild_project_names_stage_1_docker,
    local.codebuild_project_names_stage_2_docker,
    local.codebuild_project_names_stage_3_docker,
    local.codebuild_project_names_stage_4_docker,
    local.codebuild_project_names_stage_5_docker,
    local.codebuild_project_names_stage_6_docker,
    local.codebuild_project_names_stage_7_docker,
    local.codebuild_project_names_stage_8_docker
  )

  #======================
  # CodeBuild - General
  #======================
  common_name    = "hmpps-engineering-tools-builder"
  build_timeout  = "120"
  queued_timeout = "30"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn_docker_image_builder"]

  region          = var.region
  tags            = var.tags

  #======================
  # CodeBuild - Logs
  #======================

  group_name  = data.terraform_remote_state.common.outputs.dockerimagebuilder_info["log_group"]
  // stream_name = "hmpps-base-packer-ami-bake"

  #======================
  # CodeBuild - General
  #======================
  build_artifacts = {
    type = "CODEPIPELINE"
  }

  #======================
  # CodeBuild - Source
  #======================
  build_source = {
    type          = "CODEPIPELINE"
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
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true

    environment_variables = [
      {
        key = "AuthorDate"
        value = "#{SourceVariables.AuthorDate}"
      },
      {
        key="BRANCH_NAME"
        value = "#{SourceVariables.BranchName}"
      },
      {
        key="CommitId"
        value = "#{SourceVariables.CommitId}"
      },
      {
        key="CommitterDate"
        value = "#{SourceVariables.CommitterDate}"
      },
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
