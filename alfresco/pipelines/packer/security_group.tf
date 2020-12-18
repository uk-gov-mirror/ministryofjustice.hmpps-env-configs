resource "aws_security_group" "packer" {
  name        = "${local.project_name}-sg"
  description = "security group for ${local.project_name}"
  vpc_id      = local.vpc_id
  tags = merge(
    local.tags,
    {
      "Name" = "${local.project_name}-sg"
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.packer.id
  type              = "egress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.project_name}-ssh"
}

resource "aws_security_group_rule" "openvpn" {
  security_group_id = aws_security_group.packer.id
  type              = "egress"
  from_port         = "1194"
  to_port           = "1194"
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.project_name}-openvpn"
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.packer.id
  type              = "egress"
  from_port         = "80"
  to_port           = "80"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.project_name}-http"
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.packer.id
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.project_name}-https"
}
