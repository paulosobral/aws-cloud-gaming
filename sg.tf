
resource "aws_security_group" "default" {
  name = "${var.resource_name}-sg"

  tags = merge(
    local.common_tags,
    {
      Resource = "aws_security_group"
    }
  )
}

# Allow rdp connections from the local ip
resource "aws_security_group_rule" "rdp_ingress" {
  type        = "ingress"
  description = "Allow rdp connections (port 3389)"
  from_port   = 3389
  to_port     = 3389
  protocol    = "tcp"
  # cidr_blocks       = ["${data.external.local_ip.result.ip}/32"]
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

# Allow vnc connections from the local ip
resource "aws_security_group_rule" "vnc_ingress" {
  type        = "ingress"
  description = "Allow vnc connections (port 5900)"
  from_port   = 5900
  to_port     = 5900
  protocol    = "tcp"
  # cidr_blocks       = ["${data.external.local_ip.result.ip}/32"]
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

# Allow outbound connection to everywhere
resource "aws_security_group_rule" "default" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}