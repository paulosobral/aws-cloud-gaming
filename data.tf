data "aws_iam_policy" "driver_get_object_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_ami" "windows_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
}

/* data "external" "local_ip" {
  # curl should (hopefully) be available everywhere
  program = ["curl", "https://api.ipify.org?format=json"]
} */