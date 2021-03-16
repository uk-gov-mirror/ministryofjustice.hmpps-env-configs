
####################################################
# Locals
####################################################

locals {

  account_id = data.aws_caller_identity.current.account_id

  #=====================================
  # CodePipeline - Linux AMI Projects
  #=====================================
  sourcecode_action_name = "Clone-Github-SourceCode"

  artifact_store = {
    location = "tf-eu-west-2-hmpps-eng-dev-artefacts-s3bucket"
    type     = "S3"
  }

  codepipeline_builder_role = data.terraform_remote_state.common.outputs.packerbuilder_info["iam_role_arn_codepipeline"]

  code_stage = {
    action = {
      name             = "Code"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["github_source"]
      namespace        = "SourceVariables"
      configuration = {
        Owner                = "ministryofjustice"
        Repo                 = "hmpps-base-packer"
        Branch               = "master"
        PollForSourceChanges = true
      }
    }
  }

  codebuild_project_names_stage_1_linux = {
    "Centos7"      = "${local.common_name}-centos7"
    "AmazonLinux"  = "${local.common_name}-amazonlinux"
    "AmazonLinux2" = "${local.common_name}-amazonlinux2"
    "KaliLinux"    = "${local.common_name}-kalilinux"
  }

  codebuild_project_names_stage_2_linux = {
    "Centos7Docker"            = "${local.common_name}-centos7-docker"
    "AmazonLinux2Jira"         = "${local.common_name}-amazonlinux2-jira"
    "AmazonLinux2Jira7"        = "${local.common_name}-amazonlinux2-jira7"
    "AmazonLinux2Jira712"      = "${local.common_name}-amazonlinux2-jira712"
    "AmazonLinux2Jira713"      = "${local.common_name}-amazonlinux2-jira713"
    "AmazonLinux2Jira813"      = "${local.common_name}-amazonlinux2-jira813"
    "AmazonLinux2Jira815"      = "${local.common_name}-amazonlinux2-jira815"
    "AmazonLinux2Jira857"      = "${local.common_name}-amazonlinux2-jira857"
    "AmazonLinux2JenkinsAgent" = "${local.common_name}-amazonlinux2-jenkins-agent"
  }

  codebuild_project_names_stage_3_linux = {
    "Centos7DockerECS"          = "${local.common_name}-centos7-docker-ecs"
    "Centos7DockerJenkinsAgent" = "${local.common_name}-centos7-docker-jenkins-agent"
  }

  codebuild_project_names_all_linux = merge(
    local.codebuild_project_names_stage_1_linux,
    local.codebuild_project_names_stage_2_linux,
    local.codebuild_project_names_stage_3_linux
  )

  #=====================================
  # CodePipeline - Windows AMI Projects
  #=====================================
  codebuild_project_names_stage_1_windows = {
    "WindowsBase"            = "${local.common_name}-windows-base",
    "WindowsBase2019"        = "${local.common_name}-windows-base-2019"
    "WindowsBase2019Ansible" = "${local.common_name}-windows-base-2019-ansible"
  }

  codebuild_project_names_stage_2_windows = {
    "WindowsJenkinsAgent" = "${local.common_name}-windows-jenkins-agent"
    "WindowsMISNart"      = "${local.common_name}-windows-misnart"
    "WindowsMISNart2019"  = "${local.common_name}-windows-misnart-2019"
  }

  codebuild_project_names_stage_3_windows = {
    "WindowsMISNartBCS"     = "${local.common_name}-windows-misnart-bcs"
    "WindowsMISNartBFS"     = "${local.common_name}-windows-misnart-bfs"
    "WindowsMISNartBCS2019" = "${local.common_name}-windows-misnart-bcs-2019"
    "WindowsMISNartBPS2019" = "${local.common_name}-windows-misnart-bps-2019"
    "WindowsMISNartBWS2019" = "${local.common_name}-windows-misnart-bws-2019"
    "WindowsMISNartDIS2019" = "${local.common_name}-windows-misnart-dis-2019"
    "WindowsMISNartADM2019" = "${local.common_name}-windows-misnart-adm-2019"
  }

  codebuild_project_names_all_windows = merge(
    local.codebuild_project_names_stage_1_windows,
    local.codebuild_project_names_stage_2_windows,
    local.codebuild_project_names_stage_3_windows
  )

  codebuild_project_names_all = merge(
    local.codebuild_project_names_all_linux,
    local.codebuild_project_names_all_windows
  )


  #======================
  # CodeBuild - General
  #======================
  common_name    = "hmpps-base-packer-builder"
  build_timeout  = "120"
  queued_timeout = "30"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn_packer_ami_builder"]

  region = var.region
  # tags   = var.tags
  tags = merge(
    var.tags,
    {
      "source-code" = "https://github.com/ministryofjustice/hmpps-engineering-pipelines"
    }
  ) 


  #======================
  # CodeBuild - Logs
  #======================

  group_name = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
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
    type = "CODEPIPELINE"
  }

  #======================
  # CodeBuild - Environment
  #======================
  build_environment_spec = {
    compute_type = "BUILD_GENERAL1_MEDIUM" # =https://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref-compute-types.html
    images = {
      packer = data.terraform_remote_state.common.outputs.codebuild_info["packerbuilder_image"]
    }
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false

    environment_variables = [
      {
        key   = "AuthorDate"
        value = "#{SourceVariables.AuthorDate}"
      },
      {
        key   = "BRANCH_NAME"
        value = "#{SourceVariables.BranchName}"
      },
      {
        key   = "CommitId"
        value = "#{SourceVariables.CommitId}"
      },
      {
        key   = "CommitterDate"
        value = "#{SourceVariables.CommitterDate}"
      },
      {
        key   = "ARTIFACT_BUCKET"
        value = "tf-eu-west-2-hmpps-eng-dev-config-s3bucket"
      },
      {
        key   = "ZAIZI_BUCKET"
        value = "tf-eu-west-2-hmpps-eng-dev-artefacts-s3bucket"
      },
      {
        key   = "AWS_REGION"
        value = var.region
      }
    ]

  }

  #=======================
  # CodeBuild - VPC Config
  #=======================
  vpc_config = {
    vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

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

