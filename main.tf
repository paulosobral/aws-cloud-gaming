provider "aws" {
  region = var.region
}

resource "random_integer" "az_id" {
  min = 0
  max = length(var.allowed_availability_zone_identifier)
}

resource "aws_spot_instance_request" "windows_instance" {
  instance_type     = var.instance_type
  availability_zone = local.availability_zone
  ami               = (length(var.custom_ami) > 0) ? var.custom_ami : data.aws_ami.windows_ami.image_id
  security_groups   = [aws_security_group.default.name]
  user_data = var.skip_install ? "" : templatefile("${path.module}/templates/user_data.tpl", {
    password_ssm_parameter = aws_ssm_parameter.password.name,
    var = {
      instance_type                = var.instance_type,
      install_parsec               = var.install_parsec,
      install_auto_login           = var.install_auto_login,
      download_graphic_card_driver = var.download_graphic_card_driver,
      install_geforce_experience   = var.install_geforce_experience,
      install_steam                = var.install_steam,
      install_gog_galaxy           = var.install_gog_galaxy,
      install_origin               = var.install_origin,
      install_epic_games_launcher  = var.install_epic_games_launcher,
      install_uplay                = var.install_uplay,
    }
  })
  iam_instance_profile = aws_iam_instance_profile.windows_instance_profile.id

  # Spot configuration
  spot_type            = "one-time"
  wait_for_fulfillment = true

  # EBS configuration (https://docs.aws.amazon.com/pt_br/AWSEC2/latest/UserGuide/ebs-volume-types.html)
  ebs_optimized = true
  root_block_device {
    volume_type = var.root_block_device_volume_type
    volume_size = var.root_block_device_size_gb
    iops        = var.root_block_device_iops
    throughput  = var.root_block_device_throughput
  }

  tags = {
    Name = "${var.resource_name}-instance",
  }
}