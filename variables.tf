variable "aws_region" {
  description = "aws region name"
  type        = string
}

variable "aws_profile" {
  description = "aws profile name"
  type        = string
}

variable "cidr_block" {
  description = "Cidr block"
  type        = string
}
variable "vpc_tag_name" {
  description = "tag Name of Vpc"
  type        = string
}

variable "aws_account_id" {
  description = "Account Id"
  type        = string
}
