terraform {
  required_version = "= 0.11.8"
  backend "s3" {
    bucket               = "khoatdd-terraform-state"
    key                  = "terraform/aws/eks-management.tfstate"
    workspace_key_prefix = "PREFIX_PLACEHOLDER"
    region               = "us-east-2"
  }
}