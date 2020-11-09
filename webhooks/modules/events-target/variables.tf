variable "event_target_map" {
  type = map(string)
  default = {
    name                = ""
    repository          = "repo"
    source_key          = "0"
    event_source        = "eng.ci.webhooks"
    event_log_group_arn = ""
    lambda_handler_arn  = ""
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
