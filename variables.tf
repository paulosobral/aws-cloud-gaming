variable "region" {
  description = "The aws region. Choose the one closest to you: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-available-regions"
  type        = string
}

variable "tag_app_value" {
  description = "Name with which to prefix resources in AWS"
  type        = string
  default     = "aws-cloud-gaming"
}

variable "resource_name" {
  description = "Name with which to prefix resources in AWS"
  type        = string
  default     = "cloud-gaming"
}

variable "allowed_availability_zone_identifier" {
  description = "The allowed availability zone identify (the letter suffixing the region). Choose ones that allows you to request the desired instance as spot instance in your region. An availability zone will be selected at random and the instance will be booted in it."
  type        = list(string)
  default     = ["a", "b", "c"]
}

variable "instance_type" {
  description = "The aws instance type, Choose one with a CPU/GPU that fits your need: https://aws.amazon.com/ec2/instance-types/#Accelerated_Computing"
  type        = string
  default     = "g4dn.xlarge"
}

variable "root_block_device_volume_type" {
  description = "The type of the root block device (C:\\ drive) attached to the instance"
  type        = string
  default     = "gp2"
}

variable "root_block_device_size_gb" {
  description = "The size of the root block device (C:\\ drive) attached to the instance"
  type        = number
  default     = 120
}

variable "root_block_device_iops" {
  description = "The number of provisioned IOPS. This must be set with a volume_type of io1 or io2"
  type        = number
  default     = 480
}

variable "root_block_device_throughput" {
  description = "The throughput (MiB/s) that the volume supports. This must be set with a volume_type of gp3"
  type        = number
  default     = 0
}

variable "custom_ami" {
  description = "Use the specified AMI instead of the most recent windows AMI in available in the region"
  type        = string
  default     = ""
}

variable "skip_install" {
  description = "Skip installation step on startup. Useful when using a custom AMI that is already setup"
  type        = bool
  default     = false
}

variable "install_parsec" {
  description = "Download and run Parsec-Cloud-Preparation-Tool on first login"
  type        = bool
  default     = true
}

variable "install_auto_login" {
  description = "Configure auto-login on first boot"
  type        = bool
  default     = true
}

variable "download_graphic_card_driver" {
  description = "Download the Nvidia driver on first boot"
  type        = bool
  default     = true
}

variable "install_geforce_experience" {
  description = "Download and install GeForce Experience on first boot"
  type        = bool
  default     = true
}

variable "install_steam" {
  description = "Download and install Valve Steam on first boot"
  type        = bool
  default     = true
}

variable "install_gog_galaxy" {
  description = "Download and install GOG Galaxy on first boot"
  type        = bool
  default     = false
}

variable "install_uplay" {
  description = "Download and install Ubisoft Uplay on first boot"
  type        = bool
  default     = false
}

variable "install_origin" {
  description = "Download and install EA Origin on first boot"
  type        = bool
  default     = false
}

variable "install_epic_games_launcher" {
  description = "Download and install EPIC Games Launcher on first boot"
  type        = bool
  default     = false
}
