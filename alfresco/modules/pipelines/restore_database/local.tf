locals {
  environment_vars = [
    {
      "name" : "ARTEFACTS_BUCKET",
      "value" : var.pipeline_buckets["artefacts_bucket"],
      "type" : "PLAINTEXT"
    },
    {
      "name" : "PACKAGE_NAME",
      "value" : "tfpackage.tar",
      "type" : "PLAINTEXT"
    },
    {
      "name" : "BUILDS_CACHE_BUCKET",
      "value" : var.pipeline_buckets["cache_bucket"],
      "type" : "PLAINTEXT"
    }
  ]
}
