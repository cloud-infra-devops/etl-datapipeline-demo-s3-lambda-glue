terraform {
  required_version = ">= 1.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.22.1"
    }
    # vault = {
    #   source  = "hashicorp/vault"
    #   version = "5.3.0"
    # }
    # local = {
    #   source  = "hashicorp/local"
    #   version = "2.5.3"
    # }
    # random = {
    #   source  = "hashicorp/random"
    #   version = "3.7.2"
    # }
  }

  cloud {
    organization = "cloud-infra-dev"
    workspaces {
      name = "github-actions-oidc-hcp-terraform" # Workspace with VCS driven workflow
      # name    = "etl-datapipeline-demo-s3-lambda-glue" # Workspace with API driven workflow
      project = "AWS-Cloud-IaC"
    }
  }
}
provider "aws" {
  region = var.region
  # access_key = var.access_key
  # secret_key = var.secret_key
  # token      = var.token
  # assume_role {
  #   role_arn     = var.aws_assume_role_arn
  #   session_name = "GitHub_Actions-HCP_Terraform"
  # }
  allowed_account_ids = [var.aws_account_id]
}

# provider "vault" {
#   address          = var.vault_address
#   token            = var.vault_token
#   skip_child_token = "true"
# }
