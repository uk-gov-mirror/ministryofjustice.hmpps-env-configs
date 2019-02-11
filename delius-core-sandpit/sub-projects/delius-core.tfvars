# delius-core-sandpit  delius-core.tfvar
## Delius Core Specific

instance_type_weblogic = "t2.medium"
instance_count_weblogic_ndelius = "6"
instance_count_weblogic_spg = "6"
instance_count_weblogic_interface = "6"

instance_type_db = "t2.2xlarge"
#instance_type_db = "r5.large"

egress_443 = true
egress_80 = true

ndelius_version = "4.1.7.3"

ansible_vars_oracle_db = {
  service_user_name             = "oracle"
  database_global_database_name = "SANNDA"
  database_sid                  = "SANNDA"
  ## oradb_sys_password            = "/${environment_name}/delius-core/oracle-database/db/oradb_sys_password"
  ## oradb_system_password         = "/${environment_name}/delius-core/oracle-database/db/oradb_system_password"
  ## oradb_sysman_password         = "/${environment_name}/delius-core/oracle-database/db/oradb_sysman_password"
  ## oradb_dbsnmp_password         = "/${environment_name}/delius-core/oracle-database/db/oradb_dbsnmp_password"
  ## oradb_asmsnmp_password        = "/${environment_name}/delius-core/oracle-database/db/oradb_asmsnmp_password"
  database_characterset         = "AL32UTF8"
  database_bootstrap_restore    = "True" # whether primary db has db restore on bootstrap
  database_backup               = "dbbackup/dev/delius" # path in S3 to directory backup files
}

ansible_vars_apacheds = {
  apacheds_version  = "apacheds-2.0.0.AM25-default"
  ldap_protocol     = "ldap"
  # ldap_port       = "${var.ldap_ports["ldap"]}"
  bind_user         = "uid=admin,ou=system"
  # bind_password   = "/${environment_name}/delius-core/apacheds/apacheds/ldap_admin_password"
  partition_id      = "moj"
  import_users_ldif = "IFSR3-181204.ldif"
  sanitize_oid_ldif = "yes"
}

ansible_vars = {
  setup_datasources = "true"
  #s3_dependencies_bucket = derived from dependencies_bucket_arn
  database_host = "delius-db"
  alfresco_host = "alfresco"
  alfresco_office_host = "alfresco"
  ldap_host = "ldap-elb"
  spg_host = "gw-int-direct"

  ndelius_display_name = "National Delius - DEVELOPMENT USE ONLY"
  ndelius_training_mode = "development"
  ndelius_log_level = "DEBUG"
  ndelius_analytics_tag = "UA-122274748-2"
  newtech_search_url = "/newTech"
  newtech_pdfgenerator_url = "/newTech"
  usermanagement_url = "/umt/"
  nomis_url = "https://gateway.t3.nomis-api.hmpps.dsd.io/elite2api"


  domain_name = "NDelius"  # This is defined by the AMI
  server_name = "AdminServer"
  server_params = "-Xms3g -Xmx3g -XX:MaxPermSize=256m"
  jvm_mem_args = "-Xms3g -Xmx3g"
  weblogic_admin_username = "weblogic"
  #weblogic_admin_password = "/${environment_name}/delius-core/weblogic/${app_name}-domain/weblogic_admin_password"
  server_listen_address = "0.0.0.0"
  #server_listen_port = "${var.weblogic_domain_ports["ndelius_admin"]}"

  database_port = "1521"
  database_sid = "SANNDA"
  #database_password = "/${environment_name}/delius-core/oracle-database/db/delius_app_schema_password"

  activemq_data_folder = "/activemq-data"

  alfresco_port = "80"
  alfresco_office_port = "443"

  #ldap_port       = "${var.ldap_ports["ldap"]}"
  #ldap_principal = "${var.ansible_vars_apacheds["bind_user"]}"
  #ldap_admin_password = "/${environment_name}/delius-core/apacheds/apacheds/ldap_admin_password"
  #partition_id = "${var.ansible_vars_apacheds["bind_user"]}"
}
