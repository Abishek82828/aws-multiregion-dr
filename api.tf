module "api_primary" {
  source = "./modules/api-region"
  providers = {
    aws = aws.primary
  }

  project_name      = var.project_name
  table_name        = aws_dynamodb_table.items.name
  region_suffix     = "primary"
  lambda_source_dir = "${path.module}/lambda/app"
}

module "api_secondary" {
  source = "./modules/api-region"
  providers = {
    aws = aws.secondary
  }

  project_name      = var.project_name
  table_name        = aws_dynamodb_table.items.name
  region_suffix     = "secondary"
  lambda_source_dir = "${path.module}/lambda/app"

  depends_on = [aws_dynamodb_table.items]
}
