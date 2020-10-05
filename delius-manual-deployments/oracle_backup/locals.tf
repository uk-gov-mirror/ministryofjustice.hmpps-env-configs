
####################################################
# Locals
####################################################

locals {

   account_id  = data.aws_caller_identity.current.account_id

  #=====================================
  # CodePipeline - Linux AMI Projects
  #=====================================
  sourcecode_action_name = "Clone-Github-SourceCode"

  artifact_store = {
    location = "tf-eu-west-2-hmpps-eng-dev-artefacts-s3bucket"
    type     = "S3"
  }

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
          Repo                 = "delius-manual-deployments"
          Branch               = "ALS-1377"
          PollForSourceChanges = false # use git webhook
        }
      }
  }

  #======================
  # CodeBuild - General
  #======================
  common_name    = "oracle-backup"
  build_timeout  = "120"
  queued_timeout = "30"
  service_role   = "${aws_iam_role.oracle_codebuild_iam_role.arn}"
  region          = var.region
  tags            = var.tags

  #======================
  # CodeBuild - Logs
  #======================

  group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]

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
    type            = "GITHUB"
    location        = "https://github.com/ministryofjustice/delius-manual-deployments.git"
    git_clone_depth = 1
    buildspec       = "operations/oracle_backup/buildspec.yml"
  }

  #======================
  # CodeBuild - Environment
  #======================
  build_environment_spec = {
    compute_type    = "BUILD_GENERAL1_MEDIUM"
    image_pull_credentials_type = "CODEBUILD"
    image = var.code_build.ansible_image
    type = "LINUX_CONTAINER"
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