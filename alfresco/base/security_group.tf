resource "aws_security_group" "alfresco" {
  name        = "${local.common_name}-sg"
  description = "security group for ${local.common_name}"
  vpc_id      = local.vpc_id
  tags = merge(
    local.tags,
    {
      "Name" = "${local.common_name}-sg"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "docker" {
  security_group_id = aws_security_group.alfresco.id
  type              = "egress"
  from_port         = "2376"
  to_port           = "2376"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.common_name}-docker"
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.alfresco.id
  type              = "egress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.common_name}-ssh"
}

resource "aws_security_group_rule" "openvpn" {
  security_group_id = aws_security_group.alfresco.id
  type              = "egress"
  from_port         = "1194"
  to_port           = "1194"
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.common_name}-openvpn"
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.alfresco.id
  type              = "egress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.common_name}-http"
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.alfresco.id
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.common_name}-https"
}

