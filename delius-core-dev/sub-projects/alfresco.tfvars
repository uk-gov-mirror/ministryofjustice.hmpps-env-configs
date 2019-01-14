# This is used for ALB logs to S3 bucket.
# This is fixed for each region. if region changes, this changes
lb_account_id = "652711504416"

# VPC variables
cloudwatch_log_retention = 14

route53_sub_domain = "dev.alfresco"

# ROUTE53 ZONE probation.hmpps.dsd.io
route53_hosted_zone_id = "Z3VDCLGXC4HLOW"

# ALFRESCO RDS INSTANCE
rds_instance_class = "db.t2.large"

rds_backup_retention_period = 2

rds_monitoring_interval = 5

rds_allocated_storage = "1000"

# Self Signed Certs
self_signed_ca_algorithm = "RSA"

self_signed_ca_rsa_bits = "4096"

self_signed_ca_validity_period_hours = 8544

self_signed_ca_early_renewal_hours = 672

self_signed_server_algorithm = "RSA"

self_signed_server_rsa_bits = "2048"

self_signed_server_validity_period_hours = 2160

self_signed_server_early_renewal_hours = 336

# ALLOWED CIDRS

allowed_cidr_block = [
  "51.148.142.120/32",  #Brett Home
  "109.148.151.107/32", #Don Home
  "81.134.202.29/32",   #Moj VPN
  "217.33.148.210/32",  #Digital studio
  "35.176.14.16/32",    #Engineering Jenkins non prod AZ 1
  "35.177.83.160/32",   #Engineering Jenkins non prod AZ 2
  "18.130.108.149/32",  #Engineering Jenkins non prod AZ 3
  "35.178.206.119/32",  #SPG instance public NAT address
  "194.75.210.208/28",  #BCL
  "213.48.246.99/32",   #BCL
]

# ALFRESCO AMI
# OLD AMI ID: ami-054fe3c0cbbdd687e
alfresco_instance_ami = {
  az1 = "ami-08ca03668a220fa44"

  az2 = "ami-08ca03668a220fa44"

  az3 = "ami-08ca03668a220fa44"
}

# ASG Configuration
az_asg_desired = {
  az1 = "1"

  az2 = "1"

  az3 = "0"
}

az_asg_max = {
  az1 = "1"

  az2 = "1"

  az3 = "0"
}

az_asg_min = {
  az1 = "1"

  az2 = "1"

  az3 = "0"
}

asg_instance_type = "m5.xlarge"

alfresco_jvm_memory = "4G"

# common
allowed_ssh_cidr = [
  "51.148.142.120/32",  #Brett Home
  "109.148.137.148/32", #Don Home
  "81.134.202.29/32",   #Moj VPN
  "217.33.148.210/32",
] #Digital studio

alfresco_app_name = "alfresco"
