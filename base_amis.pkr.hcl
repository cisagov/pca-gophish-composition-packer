# TODO: Upgrade these base AMIs to Debian Trixie when possible.  See
# cisagov/ansible-role-pca-gophish-composition#63 for an explanation
# as to how to do this.
data "amazon-ami" "debian_bookworm_arm64" {
  filters = {
    architecture        = "arm64"
    name                = "debian-12-arm64-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["136693071363"]
  region      = var.build_region
}

data "amazon-ami" "debian_bookworm_x86_64" {
  filters = {
    architecture        = "x86_64"
    name                = "debian-12-amd64-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["136693071363"]
  region      = var.build_region
}
