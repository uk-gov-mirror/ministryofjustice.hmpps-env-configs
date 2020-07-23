// https://www.terraform.io/docs/providers/aws/r/codepipeline.html

resource "aws_codepipeline" "codepipeline_hmpps_base_packer_linux" {

  name     = "hmpps_base_packer_linux"
  role_arn = local.codepipeline_builder_role

  artifact_store {
    location = local.artifact_store.location
    type     = local.artifact_store.type
  }

  stage {
    name = local.sourcecode_action_name
    action {
      name             = local.code_stage.action.name
      category         = local.code_stage.action.category
      owner            = local.code_stage.action.owner
      provider         = local.code_stage.action.provider
      version          = local.code_stage.action.version
      output_artifacts = local.code_stage.action.output_artifacts
      namespace        = local.code_stage.action.namespace
      configuration = {
        Owner                = local.code_stage.action.configuration.Owner
        Repo                 = local.code_stage.action.configuration.Repo
        Branch               = local.code_stage.action.configuration.Branch
        PollForSourceChanges = local.code_stage.action.configuration.PollForSourceChanges
        // OAuthToken           = local.code_stage.action.configuration.OAuthToken
      }
    }
  }

  stage {
    name = "Build-Packer-Base-AMIS"

    dynamic "action" {
      
      for_each = local.codebuild_project_names_stage_1_linux
     
      content {
        name             = "Build${action.value}"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = local.code_stage.action.output_artifacts
        version          = "1"
        configuration = {
          ProjectName = action.value

          EnvironmentVariables = jsonencode([
            for e in local.build_environment_spec.environment_variables:
            {
              name  = e.key
              value = e.value
              type  = "PLAINTEXT"
            } 
          ])
          
        }
        run_order  = 1
      }

    }
  }

  stage {
    name = "Build-Centos-Docker-And-Amazon-Linux-2-Dependent-AMIs"

    dynamic "action" {
      
      for_each = local.codebuild_project_names_stage_2_linux
     
      content {
        name             = "Build${action.value}"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = local.code_stage.action.output_artifacts
        version          = "1"
        configuration = {
          ProjectName = action.value
          # EnvironmentVariables = jsonencode([
          # {
          #   name = "ENVIRONMENT"
          #   type = "PLAINTEXT"
          #   value = "test"
          # }
          # ])

          EnvironmentVariables = jsonencode([
            for e in local.build_environment_spec.environment_variables:
            {
              name  = e.key
              value = e.value
              type  = "PLAINTEXT"
            } 
          ])

        }
        run_order  = 1
      }

    }
  }

  stage {
    name = "Build-Centos-Docker-Dependant-AMIs"

    dynamic "action" {
      
      for_each = local.codebuild_project_names_stage_3_linux
     
      content {
        name             = "Build${action.value}"
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = local.code_stage.action.output_artifacts
        version          = "1"
        configuration = {
          ProjectName = action.value
          EnvironmentVariables = jsonencode([
            for e in local.build_environment_spec.environment_variables:
            {
              name  = e.key
              value = e.value
              type  = "PLAINTEXT"
            } 
          ])
        }
        run_order  = 1
      }

    }
  }
    
}
