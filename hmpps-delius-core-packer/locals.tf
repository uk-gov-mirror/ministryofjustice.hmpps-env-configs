
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

  codepipeline_builder_role = data.terraform_remote_state.common.outputs.packerbuilder_info["iam_role_arn_codepipeline"]

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
          Repo                 = "hmpps-delius-core-packer"
          Branch               = "master"
          PollForSourceChanges = false # use git webhook
        }
      }
  }
  
  codebuild_project_names_stage_1 = {
    "weblogic"      = "${local.common_name}-weblogic"
    "oracle-db"     = "${local.common_name}-oracle-db"
    "oracle-db-11g" = "${local.common_name}-oracle-db-11g"
    "oracle-db-18c" = "${local.common_name}-oracle-db-18c"
    "oracle-db-19c" = "${local.common_name}-oracle-db-19c"
    "oracle-client" = "${local.common_name}-oracle-client"
  }
  
  codebuild_project_names_stage_2 = {
    "weblogic-admin"      = "${local.common_name}-weblogic-admin"
  }

  codebuild_project_names_all = merge(
    local.codebuild_project_names_stage_1,
    local.codebuild_project_names_stage_2 
  )

  #======================
  # CodeBuild - General
  #======================
  common_name    = "hmpps-delius-core-packer-builder"
  build_timeout  = "120"
  queued_timeout = "30"
  service_role   = data.terraform_remote_state.common.outputs.codebuild_info["iam_role_arn_packer_ami_builder"]

  region          = var.region
  tags            = var.tags

  #======================
  # CodeBuild - Logs
  #======================

  group_name  = data.terraform_remote_state.common.outputs.codebuild_info["log_group"]
  // stream_name = "hmpps-delius-core-packer-ami-bake"

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
      packer    = data.terraform_remote_state.common.outputs.codebuild_info["packerbuilder_image"]
    }
    type = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
     privileged_mode             = false

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

