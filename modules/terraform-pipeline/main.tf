locals {
  name         = var.prefix
  apply_task   = var.approval_required ? "terraform_apply" : "apply"
  environment_variables = concat(
    [
      {
        name  = "ENVIRONMENT_NAME"
        type  = "PLAINTEXT"
        value = var.environment_name
      },
      {
      "name" : "BUILDS_CACHE_BUCKET",
      "value" : var.cache_bucket,
      "type" : "PLAINTEXT"
      },
      {
        "name" : "ARTEFACTS_BUCKET",
        "value" : var.artefacts_bucket,
        "type" : "PLAINTEXT"
      }
    ],
    var.environment_variables
  )
}
