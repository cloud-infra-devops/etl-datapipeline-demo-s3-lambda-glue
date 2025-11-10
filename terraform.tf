terraform {
  required_version = ">= 1.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.20.0"
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

  # backend "remote" {
  #   hostname = "app.terraform.io"
  #   organization = "cloud_infra_dev"
  #   workspaces {
  #     prefix = "github_actions_aws_"
  #   }
  # }

  # cloud {
  #   organization = "cloud_infra_dev"
  #   workspaces {
  #     name    = "github_actions_oidc_tfc"
  #     project = "AWS_IaC_Project"
  #   }
  # }
}
provider "aws" {
  region = var.region
  # access_key          = var.access_key
  # secret_key          = var.secret_key
  # token               = var.token
  allowed_account_ids = [var.aws_account_id]
}
# provider "vault" {
#   address          = var.vault_address
#   token            = var.vault_token
#   skip_child_token = "true"
# }
