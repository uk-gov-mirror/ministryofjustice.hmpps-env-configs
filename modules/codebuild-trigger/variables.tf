variable "name" {}

variable "pattern" {
  type = string
  description = "Repo head or branch"
  default = "refs/heads/develop"
}

variable "description" {
  type = string
  default = "codebuild project"
}

variable "build_timeout" {
  default     = 10
  description = "How long in minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed"
}

variable "queued_timeout" {
  default     = 60
}

variable "service_role" {
  type = string
  description = "iam role"
}

variable "tags" {
  type = map(string)
}

variable "artefacts_bucket" {
  type = string
}

variable "log_group" {
  type = string
}

variable "build_image" {
  type        = string
  default     = "aws/codebuild/standard:2.0"
  description = "Docker image for build environment, e.g. 'aws/codebuild/standard:2.0' or 'aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0'. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref.html"
}

variable "build_compute_type" {
  type        = string
  default     = "BUILD_GENERAL1_SMALL"
  description = "Instance type of the build instance"
}

variable "build_type" {
  type        = string
  default     = "LINUX_CONTAINER"
  description = "The type of build environment, e.g. 'LINUX_CONTAINER' or 'WINDOWS_CONTAINER'"
}

variable "buildspec" {
  type        = string
  default     = ""
  description = "Optional buildspec declaration to use for building the project"
}

variable "privileged_mode" {
  type        = bool
  default     = false
  description = "(Optional) If set to true, enables running the Docker daemon inside a Docker container on the CodeBuild instance. Used when building Docker images"
}

variable "image_pull_credentials_type" {
  type        = string
  default     = "SERVICE_ROLE"
}

variable "location" {
  type = string
  description = "Example https://github.com/github_org/infra_repo"
}

variable "oauth_token" {
  type = string
  default = ""
}
