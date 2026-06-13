provider "aws" {
  alias  = "primary"
  region = var.primary_region

  default_tags {
    tags = {
      Project = var.project_name
      Region  = "primary"
    }
  }
}

provider "aws" {
  alias  = "secondary"
  region = var.secondary_region

  default_tags {
    tags = {
      Project = var.project_name
      Region  = "secondary"
    }
  }
}
