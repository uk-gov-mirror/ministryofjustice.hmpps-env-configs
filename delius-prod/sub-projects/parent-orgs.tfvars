// Used to generate ECS Launch Template for SPG environment vars

// TEMPORARY CONFIG FOR PROD > PROXY >PREPROD comms


PO_SPG_CONFIGURATION = {

  #current using proxy address as pattern spg-iso-prod-p01:8181, will become more like egress-prod.psn.probation.service.justice.gov.uk/mtc/

  SPG_CERTIFICATE_BUCKET = "tf-eu-west-2-hmpps-eng-dev-certificates-private-s3bucket"
  SPG_CERTIFICATE_PATH = "/official-data/hmpps-delius-prod/current/"

  //override iso signing cert for aws prod -> po preprod testing
  SPG_ISO_SIGNING_COMMON_NAME = "signing.spgw-ext.pre-prod.probation.service.justice.gov.uk"

  //expected signed url = SPG_ISO_FQDN, ie "spgw-ext.pre-prod.probation.service.justice.gov.uk"
  SPG_ISO_UD_ALTERNATE_INBOUND_SIGNED_URL_CN = "spgw-ext-psn.probation.service.justice.gov.uk"


  #SPG_ISO_PSN_FQDN is an env var used by spg aliases to test SPG over PSN connection regardless of whether SPG
  #aliases and scripts use SPG_ISO_FQDN to test directly
  SPG_ISO_PSN_FQDN  = "spgw-int-psn.probation.service.justice.gov.uk"

  PO_ACTIVE_CONNECTIONS = "PF,STC,MTC,POSTUB"

  #THERE IS NO C00 in ND prod yet, nor an assigned crc for testing
  POSTUB_CRC_SCHEMA_0_9_13 = "C00"

  #THERE IS NO C00 in ND prod yet, nor an assigned crc for testing
  PO_POSTUB_NAME = "PO STUB"
  PO_POSTUB_TLS_COMMON_NAME = "{{ lookup('env','SPG_CRC_FQDN') }}"
  PO_POSTUB_SIGNING_COMMON_NAME = "signing.spgw-crc-ext.pre-prod.probation.service.justice.gov.uk"
  PO_POSTUB_CRC_LIST = "C00"
  PO_POSTUB_ENDPOINT_URL = "https://spgw-int-psn.probation.service.justice.gov.uk:9001/POSTUB/cxf/CRC-100"
  PO_POSTUB_PROXY_URL = "https://spgw-crc-ext.pre-prod.probation.service.justice.gov.uk:9001/cxf/CRC-100"
  #TODO rename PO_POSTUB_PROXY_URL to PO_POSTUB_PROXIED_URL


  PO_PF_NAME = "PURPLE FUTURES"
  PO_PF_CRC_LIST = "C04,C05,C06,C07,C20"
  PO_PF_TLS_COMMON_NAME = "shard-api-pre.interservefls.gse.gov.uk"
  PO_PF_SIGNING_COMMON_NAME = "signing-shard-api-pre.interservefls.gse.gov.uk"
  PO_PF_ENDPOINT_URL = "https://spgw-int-psn.probation.service.justice.gov.uk:9001/PF/cxf/CRC-100"
  PO_PF_PROXY_URL = "https://shard-api-pre.interservefls.gse.gov.uk:9001/cxf/CRC-100"


  PO_STC_NAME = "SEETEC"
  PO_STC_CRC_LIST = "C21"
  PO_STC_TLS_COMMON_NAME = "prep2.ksscrc.org.uk"
  PO_STC_SIGNING_COMMON_NAME = "signing.prep2.ksscrc.org.uk"
  PO_STC_ENDPOINT_URL = "https://spgw-int-psn.probation.service.justice.gov.uk:9001/STC/nomsinbound.svc"
  PO_STC_PROXY_URL = "https://prep2.ksscrc.org.uk:9001/nomsinbound.svc"

  PO_MTC_NAME = "MTC"
  PO_MTC_CRC_LIST = "C16,C17"
  PO_MTC_TLS_COMMON_NAME = "spg-psnppl.omnia.mtcnovo.net"
  PO_MTC_SIGNING_COMMON_NAME = "spg-iso-psnppl.omnia.mtcnovo.net"
  PO_MTC_ENDPOINT_URL = "https://spgw-int-psn.probation.service.justice.gov.uk:9001/MTC/CRC/CRCendpoint"
  PO_MTC_PROXY_URL = "https://spg-psnppl.omnia.mtcnovo.net:9001/CRC/CRCendpoint"
}


//firewall rules for parent_orgs

PO_SPG_FIREWALL_INGRESS_PORT = "9001" #9001 = switched on, 9999 = switched off

PO_SPG_FIREWALL_INGRESS_RULES = {

  DIGITAL_STUDIO_VPN = "81.134.202.29/32"
  DIGITAL_STUDIO_SHEFFIELD = "217.33.148.210/32"

  #POSTUB="no longer derived from vpc x 3 NAT as part of LB terraform as now external facing"

  PSNPROXY_A = "3.10.56.113/32"
  PSNPROXY_B = "35.178.173.171/32"


}

//IPs POs speak to
psn_facing_ips = [
  "51.231.83.120",
  "51.231.83.104"
]

//POs come in from proxy here

internet_facing_ips = [
  "3.10.56.113",
  "35.178.173.171"
]
