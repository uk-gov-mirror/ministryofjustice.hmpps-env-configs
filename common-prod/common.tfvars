region = "eu-west-2"

availability_zone = {
  az1 = "eu-west-2a"
  az2 = "eu-west-2b"
  az3 = "eu-west-2c"
}

aws_account_ids = {
  delius-core-non-prod       = "723123699647"
  hmpps-delius-auto-test     = "431912413968"
  hmpps-delius-test          = "728765553488"
  hmpps-delius-perf          = "130975965028"
  hmpps-delius-stage         = "205048117103"
  hmpps-delius-mis-dev       = "479759138745"
  hmpps-delius-mis-test      = "349354156492"
  hmpps-delius-po-test1      = "716683748953"
  hmpps-delius-po-test2      = "645753425509"
  hmpps-delius-training      = "330914586320"
  hmpps-delius-training-test = "130847504577"
  hmpps-delius-pre-prod      = "010587221707"
  hmpps-delius-prod          = "050243167760"
  hmpps-probation            = "570551521311"
  cloud-platform             = "754256621582"
}

cloudplatform_data = {
  cidr_range = "172.20.0.0/16"
}

# LB Account is used for ALB logs to S3 bucket.
# This is fixed for each region. if region changes, this changes
lb_account_id = "652711504416"

route53_domain_private = "probation.hmpps.dsd.io"

# ENVIRONMENT REMOTE STATES
eng_remote_state_bucket_name = "tf-eu-west-2-hmpps-eng-dev-remote-state"

bastion_remote_state_bucket_name = "tf-eu-west-2-hmpps-bastion-prod-remote-state"

eng_role_arn = "arn:aws:iam::895523100917:role/terraform"

bastion_role_arn = "arn:aws:iam::077643444046:role/terraform"

# required for security group rules
oracle_db_operation = {
  eng_remote_state_bucket_name = "tf-eu-west-2-hmpps-eng-prod-remote-state"
  eng_role_arn                 = "arn:aws:iam::077643444046:role/terraform"
}

alfresco_app_name = "alfresco"

spg_app_name = "spgw"

# Alfresco
# accounts used for updating alfresco ami permissions at release
alf_account_ids = {
  hmpps-delius-pre-prod = "010587221707"
  hmpps-delius-stage    = "205048117103"
  hmpps-delius-prod     = "050243167760"
  hmpps-delius-perf     = "130975965028"
  eng-non-prod          = "895523100917"
}

# ASG Configuration
alfresco_asg_props = {
  alf_deploy_iwp_fix = 1
  asg_desired        = 3
  asg_min            = 3
  asg_max            = 3
  asg_instance_type  = "m5.2xlarge"
  ebs_volume_size    = 1000
  min_elb_capacity   = 2
  ami_name           = "HMPPS Alfresco*"
}

# jvm heap
alfresco_jvm_memory = "24G"

alfresco_volume_size = 60

alf_backups_config = {
  transition_days                            = 30
  expiration_days                            = 2560
  noncurrent_version_transition_days         = 30
  noncurrent_version_transition_glacier_days = 60
  noncurrent_version_expiration_days         = 2560
  provisioned_throughput_in_mibps            = 20
  throughput_mode                            = "provisioned"
  prod_backups_bucket                        = "tf-eu-west-2-hmpps-delius-prod-alfresco-alf-backups"
  prod_storage_bucket                        = "tf-eu-west-2-hmpps-delius-prod-alfresco-storage-s3bucket"
  prod_kms_key_arn                           = "arn:aws:kms:eu-west-2:050243167760:key/f32be75c-beb8-409c-a970-db9de7201473"
}

alf_cloudwatch_log_retention = 60

# alerts
alf_ops_alerts = {
  slack_channel_name = "delius-alerts-alfresco-production"
  log_level          = "info"
  messaging_status   = "disabled"
  runtime            = "python3.7"
  ssm_token          = "/alfresco/slack/token"
}

alf_rds_props = {
  instance_class          = "db.m5.2xlarge"
  iops                    = 10000
  storage_type            = "io1"
  allocated_storage       = 1000
  maintenance_window      = "Wed:19:30-Wed:21:30"
  backup_window           = "02:00-04:00"
  backup_retention_period = 28
  family                  = "postgres9.6"
  engine                  = "postgres"
  major_engine_version    = "9.6"
  replica_engine_version  = "9.6.9"
  master_engine_version   = "9.6.9"
}

alf_database_map = {
  aurora_instance_class    = "db.r5.2xlarge"
  aurora_name              = "alf-database-svc"
  aurora_engine_version    = "9.6.19"
  aurora_replica_count     = "2"
  aurora_replica_scale_min = "2"
  aurora_replica_scale_max = "5"
  aurora_snapshot          = "alfresco-aurora-snapshot"
}

# alf solr
alf_solr_config = {
  ebs_size             = 10000
  ebs_iops             = 500
  ebs_type             = "io1"
  ebs_device_name      = "/dev/xvdc"
  java_xms             = "8000m"
  java_xmx             = "16000m"
  alf_jvm_memory       = "48G"
  schedule             = "cron(0 01 * * ? *)"
  cold_storage_after   = 14
  delete_after         = 120
  snap_tag             = "CreateSnapshotSolr"
  ebs_temp_device_name = "/dev/xvdd"
  ebs_temp_size        = 10000
  ebs_temp_type        = "gp2"
}

solr_config_overrides = {
  instance_type    = "m5.8xlarge"
  ha_instance_type = "r5.4xlarge"
  java_xms         = "16000m"
  java_xmx         = "48000m"
  alf_jvm_memory   = "48000m"
}

# ontrol rds deployment
alf_data_import = "disabled"

alf_rds_migration_parameters = [
  {
    name  = "maintenance_work_mem"
    value = 8388608
  },
  {
    name  = "max_wal_size"
    value = 256
  },
  {
    name  = "checkpoint_timeout"
    value = 1800
  },
  {
    name  = "synchronous_commit"
    value = "Off"
  },
  {
    name  = "wal_buffers"
    value = 8192
  },
  {
    name  = "autovacuum"
    value = "Off"
  }
]

alf_db_parameters = [
  {
    name         = "autovacuum_analyze_threshold"
    value        = "20000"
    apply_method = "pending-reboot"
  },
  {
    name         = "autovacuum_analyze_scale_factor"
    value        = "0.0"
    apply_method = "pending-reboot"
  },
  {
    name         = "max_connections"
    value        = "1200"
    apply_method = "pending-reboot"
  },
  {
    name         = "work_mem"
    value        = "8192"
    apply_method = "pending-reboot"
  },
  {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"
  },
  {
    name         = "track_activity_query_size"
    value        = "2048"
    apply_method = "pending-reboot"
  },
  {
    name         = "pg_stat_statements.track"
    value        = "ALL"
    apply_method = "pending-reboot"
  },
  {
    name         = "pg_stat_statements.max"
    value        = "10000"
    apply_method = "pending-reboot"
  },
  {
    name         = "log_statement"
    value        = "mod"
    apply_method = "pending-reboot"
  },
  {
    name         = "log_min_duration_statement"
    value        = "5000"
    apply_method = "pending-reboot"
  }
]

# elk
elk_backups_config = {
  transition_days                 = 28
  expiration_days                 = 2560
  provisioned_throughput_in_mibps = 20
  throughput_mode                 = "provisioned"
}

# elasticsearch
# jvm
es_jvm_heap_size = "16g"

# memory
es_ecs_memory = "26000"

es_ecs_mem_limit = "25500"

elk_migration_props = {
  min_size                        = 3
  max_size                        = 3
  desired                         = 3
  ecs_cpu_units                   = 500
  ecs_memory                      = 18000
  jvm_heap_size                   = "16g"
  image_url                       = "mojdigitalstudio/hmpps-elasticsearch-5:latest"
  kibana_image_url                = "mojdigitalstudio/hmpps-kibana-5:latest"
  logstash_image_url              = "mojdigitalstudio/hmpps-logstash:latest"
  block_device                    = "/dev/nvme0n1"
  es_master_nodes                 = 2
  ecs_service_desired_count       = 3
  instance_type                   = "i3.xlarge"
  kibana_instance_type            = "m4.large"
  kibana_desired_count            = 2
  kibana_asg_size                 = 2
  logstash_desired_count          = 2
  provisioned_throughput_in_mibps = 50
  throughput_mode                 = "provisioned"
}

# es_admin
alf_restore_status     = "restore"
es_admin_instance_type = "c5.xlarge"

es_admin_volume_props = {
  size            = 1000
  type            = "io1"
  iops            = 32000
  encrypted       = true
  device_name     = "/dev/xvdb"
  create_snapshot = false
}

## Delius Core
weblogic_domain_ports = {
  weblogic_port      = "80"
  weblogic_tls_port  = "443" # currently unused, as tls is terminated at the load-balancer
  activemq_port      = "61617"
  spg_jms_broker     = "61616"
  spg_jms_broker_ssl = "61617"
}

ldap_ports = {
  ldap     = "389"
  ldap_tls = "636" # currently unused, as the ldap can only be accessed internally
}

#SPG Partner Gateway
#Note we will be moving the ActiveMQ Broker away from servicemix and its own dedicated servers/service (AmazonMQ)

spg_partnergateway_domain_ports = {
  mutual_tls     = "9001"  # from POs unless TLS is terminated by NGINX
  internal_soap  = "8989"  # used between spg.iso and spg.mpx when they were separate modules. deprecated.
  http           = "8181"  # used from tls terminating loadbalancer, and devops ssh tunnelling
  jms_broker     = "61616" # used by SPG, ND and Alfresco consumers to push/pull JMS messages to spg.servicemix.ActiveMQ Broker
  jms_broker_ssl = "61617" # SSL version of the above

  amq_web_console     = "8161" # unsecured default port for activemq web console - not implemented
  amq_web_console_ssl = "8443" # secured default port for activemq web console - not implemented
  https               = "443"  # not yet implemented, would be used for devops non tunnelled console admin (ie hawtio)
}

# internal MOJ access
internal_moj_access_cidr_blocks = [
  "81.134.202.29/32",  #Moj VPN
  "217.33.148.210/32", #Digital studio
  "194.75.210.208/28", #BCL
  "213.48.246.99/32",  #BCL
]

# public / user access
user_access_cidr_blocks = [
  "81.134.202.29/32",  #Moj VPN
  "217.33.148.210/32", #Digital studio
  "35.176.14.16/32",   #Engineering Jenkins non prod AZ 1
  "35.177.83.160/32",  #Engineering Jenkins non prod AZ 2
  "18.130.108.149/32", #Engineering Jenkins non prod AZ 3
  "35.176.246.202/32", #Engineering Jenkins non prod windows agent
  "194.75.210.208/28", #BCL
  "213.48.246.99/32",  #BCL
  "195.59.75.0/24",    # ARK internet (DOM1)
  "194.33.192.0/25",   # ARK internet (DOM1)
  "194.33.193.0/25",   # ARK internet (DOM1)
  "194.33.196.0/25",   # ARK internet (DOM1)
  "194.33.197.0/25",   # ARK internet (DOM1)
  "212.137.36.230/32", # Quantum
  "62.25.109.197/32",  # Quantum
  "195.92.38.16/28",   # Quantum
  "62.25.106.209/32",  # OMNI
  "195.92.40.49/32",   # OMNI
  "62.232.198.64/28",  # I2N
  "3.10.56.113/32",    # PSN Proxy A
  "35.178.173.171/32", # PSN Proxy B
  "82.38.248.151/32",  # Steve James Office
  "213.86.81.13/32",   # Zaizi London Office
]

# jenkins access
jenkins_access_cidr_blocks = [
  "35.176.14.16/32",   #Engineering Jenkins non prod AZ 1
  "35.177.83.160/32",  #Engineering Jenkins non prod AZ 2
  "18.130.108.149/32", #Engineering Jenkins non prod AZ 3
  "35.176.246.202/32", #Engineering Jenkins non prod windows agent
]

#SPG has activeMQ running incomming
#database talks to activemq on spg weblogic domain
#spg talks to spg-weblogic-domain over activemq
#  # engineering
# dependencies_bucket_arn = "arn:aws:s3:::tf-eu-west-2-hmpps-eng-dev-artefacts-s3bucket"

# dev
dependencies_bucket_arn = "arn:aws:s3:::tf-eu-west-2-hmpps-eng-dev-delius-core-dependencies-s3bucket"

migration_bucket_arn = "arn:aws:s3:::tf-eu-west-2-hmpps-eng-prod-artefacts-s3bucket"

## These are the reference maps for the database sizes
## copy block into the appropriate env config file and rename

database_size_small = {
  database_size  = "small"
  instance_type  = "t3.large"
  disk_iops      = 1000
  disks_quantity = 2   # Do not decrease this
  disk_size      = 500 # Do not decrease this

  # total_storage  = 1000 # This should equal disks_quantity x disk_size
}

database_size_medium = {
  database_size  = "medium"
  instance_type  = "r5.xlarge"
  disk_iops      = 1000
  disks_quantity = 2   # Do not decrease this
  disk_size      = 500 # Do not decrease this

  # total_storage  = 1000 # This should equal disks_quantity x disk_size
}

database_size_large = {
  database_size  = "large"
  instance_type  = "r5.2xlarge"
  disk_iops      = 1000
  disks_quantity = 8    # Do not decrease this
  disk_size      = 1000 # Do not decrease this

  # total_storage  = 8000 # This should equal disks_quantity x disk_size
}

database_size_x_large = {
  database_size  = "x_large"
  instance_type  = "r5.4xlarge"
  disk_iops      = 1000
  disks_quantity = 16   # Do not decrease this
  disk_size      = 1000 # Do not decrease this

  # total_storage  = 16000 # This should equal disks_quantity x disk_size
}

database_high_availability_count = {
  delius = 2
  mis    = 2
  misboe = 2
  misdsd = 2
}

# How long we keep our indices for in elastic search in days
retention_period = 365

# How long we keep our backups on the efs share in days, we don't have a policy on s3 yet
backup_retention_days = 30

# How long do we keep our instance volume snapshots for
snapshot_retention_days = 30

# Default values for LDAP
default_ldap_config = {
  # ASG
  instance_type  = "m5.2xlarge"
  instance_count = 3
  # Connection
  protocol  = "ldap"
  port      = 389
  bind_user = "cn=admin,dc=moj,dc=com"
  #bind_password        = "${environment_name}/${project_name}/apacheds/apacheds/ldap_admin_password"
  # Structure
  base_root          = "dc=moj,dc=com"
  base_users         = "ou=Users,dc=moj,dc=com"
  base_service_users = "cn=EISUsers,ou=Users,dc=moj,dc=com"
  base_roles         = "cn=ndRoleCatalogue,ou=Users,dc=moj,dc=com"
  base_role_groups   = "cn=ndRoleGroups,ou=Users,dc=moj,dc=com"
  base_groups        = "ou=Groups,dc=moj,dc=com"
  # Logging
  log_level = "stats,sync"
  # Backups
  backup_frequency      = "hourly"
  backup_retention_days = 7
  # Performance/tuning
  query_time_limit = 30            # seconds
  db_max_size      = "53687091200" # bytes, stored on EFS (=50GB)
  # Disk (system data + logs)
  disk_volume_type = "gp2"
  disk_volume_size = 50 # GB
  # EFS (ldap data)
  efs_throughput_mode        = "provisioned"
  efs_provisioned_throughput = 64 # MiB/s
}
ldap_config = {}

# Default values for NDelius WebLogic
instance_type_weblogic            = "r5.large"   # 2 vCPU x 16GB
instance_type_activemq            = "c5.2xlarge" # 8 vCPU x 16GB
instance_count_weblogic_ndelius   = "30"
instance_count_weblogic_spg       = "3"
instance_count_weblogic_interface = "3"
default_ansible_vars = {
  # Server/WebLogic config
  jvm_mem_args            = "-Xms12g -Xmx12g -XX:MaxPermSize=512m"
  domain_name             = "NDelius" # This is defined by the AMI, so should not be overridden
  server_name             = "AdminServer"
  weblogic_admin_username = "weblogic"
  server_listen_address   = "0.0.0.0"

  # Database
  setup_datasources      = "true"
  database_host          = "delius-db"
  database_min_pool_size = 50
  database_max_pool_size = 100

  # Alfresco
  alfresco_host        = "alfresco"
  alfresco_port        = 443
  alfresco_office_host = "alfresco"
  alfresco_office_port = 443

  #spg hostname prefix for generating a url when not using amazonMQ (ie when spg_jms_host_src=var  instead of data (data mode uses the terraform state to generate the url )
  spg_jms_host = "spgw-jms-int"

  activemq_data_folder = "/activemq-data"

  # App Config
  ndelius_display_name  = "National Delius"
  ndelius_training_mode = "production" # development, training, production
  ndelius_log_level     = "ERROR"
  ndelius_analytics_tag = "UA-122274748-2"
  ldap_passfile         = "/u01/app/oracle/middleware/user_projects/domains/NDelius/password.keyfile"

  # New Tech
  newtech_search_url             = "/newTech"
  newtech_pdfgenerator_url       = "/newTech"
  newtech_pdfgenerator_templates = "shortFormatPreSentenceReport|paroleParom1Report|oralReport"
  newtech_pdfgenerator_secret    = "ThisIsASecretKey" # TODO pull from param store

  # User Management Tool
  usermanagement_url = "/umt/"

  # NOMIS
  nomis_url           = "https://gateway.preprod.nomis-api.service.hmpps.dsd.io/elite2api"
  nomis_client_id     = "delius"
  nomis_client_secret = "ThisIsASecretKey" # TODO pull from param store

  # Approved Premises Tracker API
  aptracker_api_errors_url = "/aptracker-api/errors"
}

# Delius ActiveMQ
default_activemq_config = {
  efs_throughput_mode        = "provisioned"
  efs_provisioned_throughput = 16 # MiB/s
}
activemq_config = {}

# Default ECS scaling config. Can be overridden per-service.
common_ecs_scaling_config = {
  memory       = 2048 # Memory to assign to ECS container in MB
  cpu          = 1024 # CPU to assign to ECS container (1024 units = 1 vCPU)
  min_capacity = 2    # Minimum number of running tasks
  max_capacity = 10   # Maximum number of running tasks
  target_cpu   = 60   # CPU target value for auto-scaling of ECS tasks
}

# Password Self-Service Tool (PWM)
default_pwm_config = {
  image_url = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/pwm"
  version   = "1.9.1"
}
pwm_config = {}

# UMT
default_umt_config = {
  image_url                     = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/ndelius-um"
  version                       = "1.9.0"          # Application version
  memory                        = 4096             # Additional memory required to support Redis caching
  redis_node_type               = "cache.m5.large" # Instance type to use for the Redis token store cluster
  redis_node_groups             = 2                # Number of Redis shards (node groups) in the cluster
  redis_replicas_per_node_group = 1                # Number of read-only replicas for each shard (node group)
}
umt_config = {}

# Approved Premises Tracker API
default_aptracker_api_config = {
  image_url    = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/delius-aptracker-api"
  version      = "1.13" # Application version
  log_level    = "INFO" # Application log-level
  min_capacity = 0      # Service has not yet been enabled in prod environments
  max_capacity = 0
}
aptracker_api_config = {}

# Delius GDPR compliance tool
default_gdpr_config = {
  api_image_url               = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/delius-gdpr"
  api_version                 = "0.25.1" # Application version
  cron_identifyduplicates     = "-"      # Batch schedules. Set to "-" to disable.
  cron_retainedoffenders      = "-"      #
  cron_retainedoffendersiicsa = "-"      #
  cron_eligiblefordeletion    = "-"      #
  cron_deleteoffenders        = "-"      #
  cron_destructionlogclearing = "-"      #
  ui_image_url                = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/delius-gdpr-ui"
  ui_version                  = "0.25.0"              # Application version
  ui_memory                   = 1024                  # Memory to assign to UI container
  ui_cpu                      = 512                   # CPU to assign to UI container
  db_instance_class           = "db.m5.large"         # Instance type to use for the database
  db_storage                  = 100                   # Allocated database storage in GB
  db_maintenance_window       = "Wed:21:00-Wed:23:00" # Maintenance window for database patching/upgrades
  db_backup_window            = "19:00-21:00"         # Daily window to take RDS backups
  db_backup_retention_period  = 14                    # Number of days to retain RDS backups for
  log_level                   = "INFO"                # Application log-level
}
gdpr_config = {}

# Delius Merge compliance tool
default_merge_config = {
  api_image_url              = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/delius-merge-api"
  api_version                = "0.11.1" # Application version
  api_min_capacity           = 0        # Not enabled in production yet
  api_max_capacity           = 0
  ui_image_url               = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/delius-merge-ui"
  ui_version                 = "0.11.0" # Application version
  ui_memory                  = 1024     # Memory to assign to UI container
  ui_cpu                     = 512      # CPU to assign to UI container
  ui_min_capacity            = 0        # Not enabled in production yet
  ui_max_capacity            = 0
  db_instance_class          = "db.m5.large"         # Instance type to use for the database
  db_storage                 = 100                   # Allocated database storage in GB
  db_maintenance_window      = "Wed:21:00-Wed:23:00" # Maintenance window for database patching/upgrades
  db_backup_window           = "19:00-21:00"         # Daily window to take RDS backups
  db_backup_retention_period = 14                    # Number of days to retain RDS backups for
  log_level                  = "INFO"                # Application log-level
}
merge_config = {}

# Delius API
default_delius_api_config = {
  image_url = "public.ecr.aws/hmpps/delius-api" # image_version is managed externally in CircleCI
  memory    = 4096
  cpu       = 2048
}
delius_api_config = {}

# PDF Generator
default_pdf_generator_config = {
  image_url = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/new-tech-pdfgenerator"
}
pdf_generator_config = {}

# New Tech Web Service
default_new_tech_config = {
  image_url = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/new-tech-web"

  # Default environment variables.
  # These will be overridden by CircleCI for certain environments, see https://github.com/ministryofjustice/ndelius-new-tech/blob/main/.circleci/config.yml
  env_BASE_PATH                        = "/newTech/"
  env_PARAMS_USER_TOKEN_VALID_DURATION = "1h"
  env_PRISONER_API_PROVIDER            = "elite"
  env_OFFENDER_SEARCH_PROVIDER         = "probation-offender-search"
  env_STORE_PROVIDER                   = "alfresco"
  env_STORE_ALFRESCO_USER              = "N00"
  env_DELIUS_API_BASE_URL              = "http://community-api.ecs.cluster:8080/api/"
  env_PDF_GENERATOR_URL                = "http://pdf-generator.ecs.cluster:8080/"
  env_HMPPS_AUTH_BASE_URL              = "https://sign-in-preprod.hmpps.service.justice.gov.uk/"
  env_NOMIS_API_BASE_URL               = "https://api-preprod.prison.service.justice.gov.uk/"
  env_PROBATION_OFFENDER_SEARCH_URL    = "https://probation-offender-search-preprod.hmpps.service.justice.gov.uk/"
}
new_tech_config = {}

# Community API
default_community_api_config = {
  image_url        = "quay.io/hmpps/community-api"
  memory           = 4096
  cpu              = 2048
  enable_public_lb = false

  # Default environment variables.
  # These will be overridden by CircleCI for certain environments, see https://github.com/ministryofjustice/community-api/blob/main/.circleci/config.yml
  env_SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_JWK_SET_URI = "https://sign-in-preprod.hmpps.service.justice.gov.uk/auth/.well-known/jwks.json"
}
community_api_config = {}
default_community_api_ingress = [ # Common CIDR ranges for ingress in all production environments
  "35.178.209.113/32",            # cloudplatform-live1-1
  "3.8.51.207/32",                # cloudplatform-live1-2
  "35.177.252.54/32",             # cloudplatform-live1-3
  "35.177.252.195/32",            # healthkick
  "34.252.4.39/32",               # Analytics platform
  "34.251.212.33/32",             # Analytics platform
  "34.250.17.221/32",             # Analytics platform
  "34.247.31.101/32",             # Analytics platform
  "3.248.11.160/32",              # Analytics platform
  "54.194.123.60/32",             # Analytics platform
  "34.249.60.91/32",              # Analytics platform
  "34.251.199.153/32",            # Analytics platform
  "34.249.194.106/32",            # Analytics platform
  "194.168.183.130/32",           # CATS+ access (Daresbury Office)
  "51.141.53.111/32",             # Public IP of azure fortinet (prod)
]
community_api_ingress = [] # Override this per-environment for specific ingress rules

# Delius-Core Slack alarms:
delius_alarms_config = {
  enabled     = true
  quiet_hours = [23, 3] # 23:00-03:00 to coincide with WebLogic nightly restart
}

# DSS Batch Task
dss_batch_instances = ["m5.large", "c5.large"]

dss_min_vcpu = 0

dss_max_vcpu = 8

dss_job_image = "895523100917.dkr.ecr.eu-west-2.amazonaws.com/hmpps/dss:3.1.6"

dss_job_vcpus = 1

dss_job_memory = 3096

dss_job_schedule = "cron(00 8 * * ? *)"

dss_job_retries = 1

dss_queue_state = "ENABLED"

dss_job_ulimits = [
  {
    "name"      = "nofile"
    "hardLimit" = "1024"
    "softLimit" = "1024"
  },
]

# Testing/Chaosmonkey
ce_instances = ["m5.large", "c5.xlarge"]

ce_min_vcpu = 0

ce_max_vcpu = 8

ce_queue_state = "ENABLED"

chaosmonkey_job_image = "mojdigitalstudio/hmpps-chaosmonkey:latest"

chaosmonkey_job_vcpus = 1

chaosmonkey_job_memory = 512

chaosmonkey_job_retries = 1

chaosmonkey_job_envvars = [
  {
    "name"  = "SIMIANARMY_CLIENT_LOCALDB_ENABLED"
    "value" = "true"
  },
  {
    "name"  = "SIMIANARMY_CALENDAR_TIMEZONE"
    "value" = "Europe/London"
  },
  {
    "name"  = "SIMIANARMY_CHAOS_LEASHED"
    "value" = "true"
  },
  {
    "name"  = "SIMIANARMY_CALENDAR_OPENHOUR"
    "value" = "9"
  },
  {
    "name"  = "SIMIANARMY_CALENDAR_CLOSEHOUR"
    "value" = "17"
  },
  {
    "name"  = "SIMIANARMY_CLIENT_AWS_REGION"
    "value" = "eu-west-2"
  },
]

chaosmonkey_job_ulimits = []

delius_core_haproxy_instance_type  = "t3.large"
delius_core_haproxy_instance_count = "3"

# Shared ECS Cluster
ecs_instance_type = "m4.xlarge"
node_max_count    = 30
node_min_count    = 5

loadrunner_config = {
  "instance_type" = "t3.large"
}

azure_oasys_proxy_source = [
  "51.140.255.11/32" # Public IP of Fix & Go Azure API Gateway used for NDH
]

#these 3 vars dictate whether or not to use AmazonMQ, vs spg-mpx-broker ('data'|'var')
#var = spg local MQ, data = amazon mq
SPG_GATEWAY_MQ_URL_SOURCE    = "data"
spg_messaging_broker_url_src = "data"
spg_jms_host_src             = "data"

# Parent R53 Zone ID for strategic domain (probation.service.justice.gov.uk)
strategic_parent_zone_id              = "Z2SOZ79CNGAPIF"
strategic_parent_zone_delegation_role = "arn:aws:iam::050243167760:role/r53_delegation_role"

# ACM alerts
acm_alerts_config = {
  slack_channel = "delius-aws-acm-alerts"
}
