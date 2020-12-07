resource "aws_security_group" "mis" {
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

resource "aws_security_group_rule" "nextcloud" {
  security_group_id = aws_security_group.mis.id
  type              = "egress"
  from_port         = "3306"
  to_port           = "3306"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.common_name}-nextcloud-db-out"
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.mis.id
  type              = "egress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${local.common_name}-https-out"
}
