# delius-training-test  delius-core.tfvars
## Delius Core Specific

# ref ../../common/common.tfvars
db_size_delius_core = {
  database_size       = "small"
  instance_type       = "t3.large"
  disks_quantity      = 2 # Do not decrease this
  disks_quantity_data = 1
  disk_iops_data      = 1000
  disk_iops_flash     = 500
  disk_size_data      = 200 # Do not decrease this
  disk_size_flash     = 200 # Do not decrease this
  ## total_storage    = 400 # This should equal disks_quantity x disk_size
}

ansible_vars_oracle_db = {
  service_user_name             = "oracle"
  database_global_database_name = "TRTNDA"
  database_sid                  = "TRTNDA"
  ## oradb_sys_password            = "/${environment_name}/delius-core/oracle-database/db/oradb_sys_password"
  ## oradb_system_password         = "/${environment_name}/delius-core/oracle-database/db/oradb_system_password"
  ## oradb_dbsnmp_password         = "/${environment_name}/delius-core/oracle-database/db/oradb_dbsnmp_password"
  ## oradb_asmsnmp_password        = "/${environment_name}/delius-core/oracle-database/db/oradb_asmsnmp_password"
  database_characterset      = "AL32UTF8"
  database_bootstrap_restore = "True"                                                                        # whether primary db has db restore on bootstrap
  database_backup            = "dbbackup/dev/delius"                                                         # path in S3 to directory backup files
  database_backup_sys_passwd = "/dbbackup/delius-core-dev/delius-core/oracle-database/db/oradb_sys_password" # ssm parameter store name for db backup password
  database_backup_location   = "/u01/backup"                                                                 #default for local testing
  oracle_dbca_template_file  = "database"
}

# WebLogic
ansible_vars = {
  ndelius_display_name  = "National Delius - TEST USE ONLY"
  ndelius_training_mode = "training"
  database_sid          = "TRTNDA"
}

env_user_access_cidr_blocks = [
  # Parent Organisation IP ranges
  # -MTCNovo
  "62.25.109.202/32", # MTCNovo old frontend desktops Egress IP (Pre March 2021)
  "192.57.152.98/32", # MTCNovo new frontend desktops Egress IP (March 2021 on)

  # -SEETEC
  "80.86.46.16/30",
  "195.224.76.229/32",
  "51.179.199.82/32", #ROK user outbound for wales,DDC,BGSW - requested via slack support channel https://mojdt.slack.com/archives/GNXRQ5HUN/p1570199298064800

  # -Interserve
  "46.227.51.224/29",
  "46.227.51.232/29",
  "46.227.51.240/28",
  "51.179.196.131/32",

  # -Meganexus
  "51.179.210.36/32",
  "83.151.209.178/32",  # PF SPG Server Public IP/NAT
  "83.151.209.179/32",  # PF SPG Server Public IP/NAT 2
  "213.105.186.130/31", # Meganexus London (Firewall IP + Gateway IP)
  "202.189.235.70/32",  # Meganexus India

  # -Sodexo Justice Services
  "80.86.46.16/31",
  "80.86.46.18/32",

  # -RRP (Reducing Reoffending Partnership)
  "62.253.83.37/32",

  # - ARCC/DTV (Achieving Real Change in Communities - Durham & Tees Valley)
  "51.179.197.1/32",

  # - EOS
  "5.153.255.210/32", # EOS Public IP

  # -Sopra Steria
  "195.206.180.12/32", # Dedicated IP provided by Nicki Berry on 26/02/2020
]

# DSS Batch Task
dss_job_envvars = [
  {
    "name"  = "DSS_TESTMODE"
    "value" = "true"
  },
  {
    "name"  = "DSS_TESTINGAUTOCORRECT"
    "value" = "true"
  },
  {
    "name"  = "DSS_ENVIRONMENT"
    "value" = "delius-training-test"
  },
  {
    "name"  = "DSS_DSSWEBSERVERURL"
    "value" = "https://interface-app-internal.training-test.delius.probation.hmpps.dsd.io/NDeliusDSS/UpdateOffender"
  },
  {
    "name"  = "DSS_PROJECT"
    "value" = "delius"
  }
]

# Use dsd.io public zone until transition to gov.uk is complete for this environment
delius_core_public_zone = "legacy"
