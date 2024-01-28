resource "random_password" "password" {
  length  = 32
  special = true
}

resource "aws_ssm_parameter" "password" {
  name  = "${var.resource_name}-administrator-password"
  type  = "SecureString"
  value = random_password.password.result

  tags = merge(
    local.common_tags,
    {
      Resource = "aws_ssm_parameter"
    }
  )
}