# Configure AWS
provider "aws" {
  region = "us-east-1"
}

module "iam_user" {
  source = "github.com/cisagov/molecule-packer-travisci-iam-user-tf-module"

  add_packer_permissions = true
  ssm_parameters         = ["/cyhy/dev/users", "/ssh/public_keys/*", "/vnc/username", "/vnc/password", "/vnc/ssh/rsa_public_key", "/vnc/ssh/rsa_private_key"]
  user_name              = "test-pca-gophish-composition-packer"
  tags = {
    Team        = "CISA - Development"
    Application = "pca-gophish-composition-packer"
  }
}
