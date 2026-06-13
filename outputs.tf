output "primary_api_endpoint" {
  value = module.api_primary.api_endpoint
}

output "secondary_api_endpoint" {
  value = module.api_secondary.api_endpoint
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.items.name
}

output "dr_zone_name_servers" {
  description = "Add these as NS records at your domain registrar for dr.example.com"
  value       = aws_route53_zone.dr.name_servers
}

output "failover_dns_name" {
  description = "The failover endpoint - use this in your demo/README"
  value       = local.failover_record_name
}
