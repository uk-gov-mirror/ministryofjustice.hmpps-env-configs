module "dev-event" {
  source                = "../../modules/events"
  name                  = "delius-mis-dev"
  schedule_expression   = var.schedule_expression
  account_id            = local.account_id
  prefix                = local.prefix
  tags                  = var.tags
  region                = var.region
}

module "auto-test-event" {
  source                = "../../modules/events"
  name                  = "delius-auto-test"
  schedule_expression   = var.schedule_expression
  account_id            = local.account_id
  prefix                = local.prefix
  tags                  = var.tags
  region                = var.region
}

module "stage-event" {
  source                = "../../modules/events"
  name                  = "delius-stage"
  schedule_expression   = var.schedule_expression
  account_id            = local.account_id
  prefix                = local.prefix
  tags                  = var.tags
  region                = var.region
}

module "pre-prod-event" {
  source                = "../../modules/events"
  name                  = "delius-pre-prod"
  schedule_expression   = var.schedule_expression
  account_id            = local.account_id
  prefix                = local.prefix
  tags                  = var.tags
  region                = var.region
}

module "prod-event" {
  source                = "../../modules/events"
  name                  = "delius-prod"
  schedule_expression   = var.schedule_expression
  account_id            = local.account_id
  prefix                = local.prefix
  tags                  = var.tags
  region                = var.region
}
