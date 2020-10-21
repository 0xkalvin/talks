variable "profile" {
  type        = "string"
  default     = "default"
  description = "AWS profile name"
}

variable "region" {
  type        = "string"
  default     = "us-east-1"
  description = "AWS default account region"
}

variable "environment" {
  type    = "string"
  default = "production"
}
