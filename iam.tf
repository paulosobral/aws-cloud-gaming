resource "aws_iam_role" "windows_instance_role" {
  name               = "${var.resource_name}-instance-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(
    local.common_tags,
    {
      Resource = "aws_iam_role"
    }
  )
}

resource "aws_iam_policy" "password_get_parameter_policy" {
  name   = "${var.resource_name}-password-get-parameter-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ssm:GetParameter",
      "Resource": "${aws_ssm_parameter.password.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "password_get_parameter_policy_attachment" {
  role       = aws_iam_role.windows_instance_role.name
  policy_arn = aws_iam_policy.password_get_parameter_policy.arn
}

resource "aws_iam_role_policy_attachment" "driver_get_object_policy_attachment" {
  role       = aws_iam_role.windows_instance_role.name
  policy_arn = data.aws_iam_policy.driver_get_object_policy.arn
}

resource "aws_iam_instance_profile" "windows_instance_profile" {
  name = "${var.resource_name}-instance-profile"
  role = aws_iam_role.windows_instance_role.name
}