// https://www.terraform.io/docs/providers/aws/r/codepipeline.html

resource "aws_codepipeline" "codepipeline_hmpps_engineering_tools" {

  name     = "hmpps-engineering-tools-docker-images-builder"
  role_arn = local.codepipeline_dockerimagebuilder_role

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
    name = "create-aws-ecr-repositories"

    action {
      name             = "hmpps-engineering-tools-create-ecr-repos"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = local.code_stage.action.output_artifacts
      output_artifacts = ["create_ecr_repos_output"]
      version          = "1"

      configuration = {
          ProjectName = "hmpps-engineering-tools-create-ecr-repos"
          EnvironmentVariables = jsonencode([
            for e in local.build_environment_spec.environment_variables:
            {
              name  = e.key
              value = e.value
              type  = "PLAINTEXT"
            } 
          ])
        }
    }
  }

  # stage {
  #   name = "install-semver-and-tag-repository"

  #   action {
  #     name             = "hmpps_engineering_tools_semver_tag_repo"
  #     category         = "Build"
  #     owner            = "AWS"
  #     provider         = "CodeBuild"
  #     input_artifacts  = local.code_stage.action.output_artifacts
  #     output_artifacts = ["tag_repos_output"]
  #     version          = "1"

  #     configuration = {
  #         ProjectName = "hmpps_engineering_tools_semver_tag_repo"
  #         EnvironmentVariables = jsonencode([
  #           for e in local.build_environment_spec.environment_variables:
  #           {
  #             name  = e.key
  #             value = e.value
  #             type  = "PLAINTEXT"
  #           } 
  #         ])
  #       }
  #   }
  # }
    
  stage {
    name = "build-base-images"

    dynamic "action" {
      for_each = local.codebuild_project_names_stage_1_docker
      content {
        name             = "build-${action.value}"
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
    name = "build-base-dependant-images"

    dynamic "action" {
      for_each = local.codebuild_project_names_stage_2_docker
      content {
        name             = "build-${action.value}"
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


  # stage('Ansible base dependant images') {
  stage {
    name = "build-ansible-base-dependant-images"

    dynamic "action" {
      for_each = local.codebuild_project_names_stage_3_docker
      content {
        name             = "build-${action.value}"
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
  
  
  # stage('Nginx base dependant images') {
  stage {
    name = "build-nginx-base-dependant-images"

    dynamic "action" {
      for_each = local.codebuild_project_names_stage_4_docker
      content {
        name             = "build-${action.value}"
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
  # stage('base-java dependant images') {
  stage {
    name = "build-base-java-dependant-images"

    dynamic "action" {
      for_each = local.codebuild_project_names_stage_5_docker
      content {
        name             = "build-${action.value}"
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
  # stage('base-java-openrc dependant images') {
  stage {
    name = "build-base-java-openrc-dependant-images"

    dynamic "action" {
      for_each = local.codebuild_project_names_stage_6_docker
      content {
        name             = "build-${action.value}"
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
  # stage('Python 3 base dependant images') {
  stage {
    name = "build-python-3-base-dependant-images"

    dynamic "action" {
      for_each = local.codebuild_project_names_stage_7_docker
      content {
        name             = "build-${action.value}"
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
  # stage('Non Dependant Images') {
  stage {
    name = "build-non-dependant-images"

    dynamic "action" {
      for_each = local.codebuild_project_names_stage_8_docker
      content {
        name             = "build-${action.value}"
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
