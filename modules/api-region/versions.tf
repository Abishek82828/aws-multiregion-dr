terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws]
    }
    archive = {
      source = "hashicorp/archive"
    }
  }
}
