variable "project_name" {
  description = "Name prefix used for all resources"
  type        = string
  default     = "dr-demo"
}

variable "primary_region" {
  description = "Primary (active) AWS region"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary (standby/DR) AWS region"
  type        = string
  default     = "us-west-2"
}

variable "root_domain" {
  description = "Root domain you own (e.g. madtamizha.com). A 'dr' subdomain hosted zone will be created under it."
  type        = string
  default     = "madtamizha.com"
}
