resource "aws_dynamodb_table" "items" {
  provider = aws.primary

  name         = "${var.project_name}-items"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  replica {
    region_name = var.secondary_region
  }

  point_in_time_recovery {
    enabled = true
  }
}
