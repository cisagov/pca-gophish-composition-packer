module "iam_user" {
  source = "github.com/cisagov/ami-build-iam-user-tf-module"

  providers = {
    aws            = aws
    aws.images-ami = aws.images-ami
    aws.images-ssm = aws.images-ssm
  }

  ssm_parameters = [
    "/vnc/password",
    "/vnc/ssh/ed25519_private_key",
    "/vnc/ssh/ed25519_public_key",
    "/vnc/username",
  ]
  user_name = "build-pca-gophish-composition-packer"
}
