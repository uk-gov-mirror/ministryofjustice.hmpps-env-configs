resource "aws_cloudwatch_event_rule" "oracle_backup_cloudwatch_event_rule" {

  for_each = { for job in var.oracle_backup_jobs: "${job.type}-${job.environment}-${job.host}" => job }

    name                = "oracle-backup-rule-${each.key}"
    schedule_expression = each.value.schedule
    description         = "Oracle ${each.value.type} backup schedule for ${each.value.host} on ${each.value.environment}"
    is_enabled          = true
}

resource "aws_cloudwatch_event_rule" "oracle_validate_backup_cloudwatch_event_rule" {

  for_each = { for job in var.oracle_validate_backup_jobs: "${job.environment}-${job.host}" => job }

    name                = "oracle-validate-rule-${each.key}"
    schedule_expression = each.value.schedule
    description         = "Oracle validate backup schedule for ${each.value.host} on ${each.value.environment}"
    is_enabled          = true
}

resource "aws_cloudwatch_event_target" "oracle_backup_pipeline_cloudwatch_event_target" {

  for_each = aws_codepipeline.oracle_backups_codepipeline

    rule      = aws_cloudwatch_event_rule.oracle_backup_cloudwatch_event_rule[each.key].name
    target_id = "Codepipeline"
    arn       = aws_codepipeline.oracle_backups_codepipeline[each.key].arn
    role_arn  = local.service_role
}

resource "aws_cloudwatch_event_target" "oracle_validate_backup_cloudwatch_event_target" {

  for_each = aws_codebuild_project.oracle_validate_backup_codebuild_project

    rule      = aws_cloudwatch_event_rule.oracle_validate_backup_cloudwatch_event_rule[each.key].name
    target_id = "Codepipeline"
    arn       = aws_codebuild_project.oracle_validate_backup_codebuild_project[each.key].arn
    role_arn  = local.service_role
}
