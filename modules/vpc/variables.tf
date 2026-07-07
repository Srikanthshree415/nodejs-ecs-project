variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "name_prefix" {
  description = "Name prefix for resources"
  type        = string
}

variable "common_tags" {
  description = "Common tags to be applied to resources"
  type        = map(string)
  default     = {}
}
