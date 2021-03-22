vpc_supernet = "10.160.16.0/20"

aws_nameserver = "10.160.16.2"

public_ssl_arn = ""

## Delius Core Specific

instance_type_db = "t2.large"

route53_domain_private = "service.justice.gov.uk"

subdomain = "probation"

#Instance size for smtp server
smtp_instance_type = "m5.xlarge"

oracle_backup_schedule = {
  delius = {
    daily_schedule  = "00 03 ? * 2-7 *"
    weekly_schedule = "00 03 ? * 1 *"
  },
  mis = {
    daily_schedule  = "00 00 ? * 2-7 *"
    weekly_schedule = "00 00 ? * 1 *"
  },
  misboe = {
    daily_schedule  = "00 03 ? * 2-7 *"
    weekly_schedule = "00 03 ? * 1 *"
  },
  misdsd = {
    daily_schedule  = "00 03 ? * 2-7 *"
    weekly_schedule = "00 03 ? * 1 *"
  }
}

oracle_validate_backup_schedule = {
  delius = {
    host     = "delius_standbydb2"
    schedule = "00 15 ? * 4 *"
  },
  mis = {
    host     = "mis_standbydb2"
    schedule = "00 15 ? * 4 *"
  },
  misboe = {
    host     = "misboe_standbydb2"
    schedule = "00 15 ? * 4 *"
  }
  misdsd = {
    host     = "misdsd_standbydb2"
    schedule = "00 15 ? * 4 *"
  }
}

oracle_delete_unused_dbids = "no"