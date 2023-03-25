
# ---------------------------
# Terraform configuration
# ---------------------------
terraform {
  required_version = ">=0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

# ---------------------------
# provider
# ---------------------------

provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
}

# ---------------------------
# variables
# ---------------------------

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "domain" {
  type = string

}
