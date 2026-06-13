variable "project_name" {
  type = string
}

variable "table_name" {
  description = "Name of the DynamoDB global table (same in every region)"
  type        = string
}

variable "region_suffix" {
  description = "Label for this deployment, e.g. primary or secondary"
  type        = string
}

variable "lambda_source_dir" {
  description = "Path to the Lambda function source code"
  type        = string
}
