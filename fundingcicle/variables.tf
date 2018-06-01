variable "cidr" {
  description = "The CIDR block for the VPC."
  default     = "192.168.0.0/16"
}

variable "enable_dns_support" {
  default = "true"
}

variable "enable_dns_hostnames" {
  default = "true"
}

variable "environment" {
  description = "Environment tag, recommendation: <account name>_<region>, e.g. prod_us-west-2"
  default = "dev"
}

variable "private_cidr" {
  description = "CIDR for private subnet"
  default     = "192.168.1.0/24"
}

variable "public_cidr" {
  description = "CIDR for private subnet"
  default     = "192.168.0.0/24"
}

variable "aws_region" {
  description = "Aws Region"
  default = "us-east-1"
}
