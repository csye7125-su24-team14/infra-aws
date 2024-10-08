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

# Helm Autoscaler Values 
variable "github_token" {
  description = "Github token"
  type        = string
}

variable "github_orgname" {
  description = "Github orgname"
  type        = string
}

variable "github_autoscaler_repo" {
  description = "Github repo"
  type        = string
}

variable "github_operator_repo" {
  description = "Github repo"
  type        = string
}

variable "github_postgres_repo" {
  description = "Github repo"
  type        = string
}

variable "dockerconfigjson" {
  description = "Docker config"
  type        = string
}

variable "hostedZoneId" {
  description = "Hosted Zone Id"
  type        = string
}

variable "account_id" {
  description = "Account Id"
  type        = string
}

variable "PINECONE_HOST" {
  description = "Pinecone Host"
  type        = string
}

variable "PINECONE_API_KEY" {
  description = "Pinecone API Key"
  type        = string
}

variable "GROQ_API_KEY" {
  description = "GROQ API"
  type        = string
}