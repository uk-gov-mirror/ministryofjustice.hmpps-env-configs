locals {
  s3_cache_enabled = var.cache_type == "S3"
  cache_options = {
    "S3" = {
      type     = "S3"
      location = var.enabled && local.s3_cache_enabled ? join("", var.cache_bucket) : "none"

    },
    "LOCAL" = {
      type  = "LOCAL"
      modes = var.local_cache_modes
    },
    "NO_CACHE" = {
      type = "NO_CACHE"
    }
  }
  cache = local.cache_options[var.cache_type]
}
