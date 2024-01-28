locals {
  availability_zone = "${var.region}${element(var.allowed_availability_zone_identifier, random_integer.az_id.result)}"
  common_tags = {
    App = var.tag_app_value
  }
}