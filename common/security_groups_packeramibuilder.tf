############################################
# CodePipeline, CodeBuild packerbuilder_client_security_group
############################################

resource "aws_security_group" "packerbuilder_client_security_group" {
  name        = "${var.environment_identifier}-packerbuilder-client-sg"
  description = "security group for ${var.environment_identifier}-vpc-packerbuilder-internal-access"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  tags = merge(
      local.tags,
      {
        "Name" = "${var.environment_identifier}-packerbuilder-client-sg"
        "Type" = "Private"
      },
    )
}

resource "aws_security_group_rule" "packerbuilder_agent_ingress_all" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "ingress"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  self              = true
  description       = "Packer Builder Agent Access Self All"
}

resource "aws_security_group_rule" "packerbuilder_agent_egress_all" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "egress"
  from_port         = 0
  protocol          = "-1"
  to_port           = 0
  self              = true
  description       = "Packer Builder Agent Access Self All"
}

resource "aws_security_group_rule" "packerbuilder_agent_egress_http" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "egress"
  from_port         = 80
  protocol          = "tcp"
  to_port           = 80

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  description = "Packer Builder Agent Access HTTP All"
}

resource "aws_security_group_rule" "packerbuilder_agent_egress_https" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "egress"
  from_port         = 443
  protocol          = "tcp"
  to_port           = 443

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  description = "Packer Builder Agent Access HTTPS All"
}

resource "aws_security_group_rule" "packerbuilder_agent_egress_ssh" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "egress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  description = "Packer Builder Agent Access SSH All"
}

resource "aws_security_group_rule" "packerbuilder_agent_egress_ssh_22" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "egress"
  from_port         = 2222
  to_port           = 2222
  protocol          = "tcp"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  description = "Packer Builder Agent Access SSH (2222) All"
}

# TODO remove this access after updating HA Build packerbuilder Job
resource "aws_security_group_rule" "packerbuilder_agent_egress_oracle_db" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "egress"
  from_port         = 1521
  to_port           = 1521
  protocol          = "tcp"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  description = "Packer Builder Agent Access Oracle-Db All"
}

resource "aws_security_group_rule" "packerbuilder_agent_egress_WinRM_hhtp" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "egress"
  from_port         = 5985
  to_port           = 5985
  protocol          = "tcp"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  description = "WinRM http port"
}

resource "aws_security_group_rule" "packerbuilder_agent_egress_WinRM_https" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "egress"
  from_port         = 5986
  to_port           = 5986
  protocol          = "tcp"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  description = "WinRM https port"
}

resource "aws_security_group_rule" "packerbuilder_agent_egress_postgres_db" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "egress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  description = "Packer Builder Agent Access Postgress-Db All"
}

#packerbuilder out maria db
resource "aws_security_group_rule" "packerbuilder_agent_egress_maria_db" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  description = "packerbuilder Agent Access Maria-Db All"
}

# packerbuilder docker tls
resource "aws_security_group_rule" "packerbuilder_agent_egress_docker_tls" {
  security_group_id = aws_security_group.packerbuilder_client_security_group.id
  type              = "egress"
  from_port         = 2376
  to_port           = 2376
  protocol          = "tcp"

  cidr_blocks = [
    "0.0.0.0/0",
  ]

  description = "Packer Builder Agent Access dockers-tls All"
}

// resource "aws_security_group_rule" "packerbuilder_agent_ingress_ping" {
//   security_group_id = aws_security_group.packerbuilder_client_security_group.id
//   type              = "ingress"
//   protocol          = "icmp"
//   from_port         = "8"
//   to_port           = "0"
//   cidr_blocks       = ["10.0.0.0/8"]
//   description       = "Packer Builder Agent Ping in local"
// }

################################
#packerbuilder INSTANCE instance
################################

resource "aws_security_group" "packerbuilder_instance_security_group" {
  name        = "${var.environment_identifier}-packerbuilder-instance-sg"
  description = "${var.environment} security group for ${var.environment_identifier}-packerbuilder"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  tags = merge(
      local.tags,
      {
        "Name" = "${var.environment_identifier}-packerbuilder-instance-sg"
        "Type" = "Private"
      },
    )
}
