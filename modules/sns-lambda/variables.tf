variable "name" {}

variable "lambda_filename" {
  description = "Zip file containing Lambda files."
  type        = string
}

variable "lambda_role_arn" {
  description = "Role ARN to use for the Lambda function."
  type        = string
}

variable "lambda_handler" {
  description = "Name of the entry point method in the Lambda function."
  type        = string
  default     = "lambda.handler"
}

variable "lambda_runtime" {
  description = "Runtime to use for the Lambda function."
  type        = string
  default     = "nodejs12.x"
}

variable "environment" {
  description = "Environment variables to pass to the Lambda function."
  type        = map(string)
  default     = {}
}

variable "sns_publishers" {
  description = "List of AWS principals that should be allowed access to publish notifications to the SNS topic. Defaults to allowing access from Amazon EventBridge."
  type = list(object({
    type        = string
    identifiers = list(string)
  }))
  default = [{
    type        = "Service"
    identifiers = ["events.amazonaws.com"]
  }]
}

variable "tags" {
  type = map(string)
}

