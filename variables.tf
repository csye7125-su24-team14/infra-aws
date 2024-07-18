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

# EKS Cluster Variables

variable "cluster_name" {
  description = "EKS Cluster Name"
  type        = string
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  type        = string
}

variable "aws_first_user" {
  description = "AWS First Username"
  type        = string
}

variable "aws_second_user" {
  description = "AWS Second Username"
  type        = string
}

# Helm Postgres Values
variable "postgres_username" {
  description = "Postgres username"
  type        = string
}

variable "postgres_password" {
  description = "Postgres password"
  type        = string
}

variable "postgres_database" {
  description = "Postgres database"
  type        = string
}


# Helm Kafka Values
variable "kafka_username" {
  description = "Kafka username"
  type        = string
}

variable "kafka_password" {
  description = "Kafka password"
  type        = string
}

variable "github_username" {
  description = "Github username"
  type        = string
}

variable "github_password" {
  description = "Github password"
  type        = string
}