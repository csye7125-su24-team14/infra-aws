# infra-aws

`terraform fmt  -recursive `
`terraform fmt -check -recursive`

# AWS EKS Infrastructure with Kafka, PostgreSQL, and Cluster Autoscaler

## Overview

This Terraform project sets up an Amazon EKS (Elastic Kubernetes Service) cluster on AWS, along with the necessary networking infrastructure. It also includes Helm chart installations for Apache Kafka, PostgreSQL, and Cluster Autoscaler.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (version 1.0.0 or later)
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/intro/install/)

## Configuration

1. Clone this repository:
   `git clone <repository-url>`
   `cd <repository-directory>`

2. Update `variables.tf` with your desired configurations.

3. Initialize Terraform:
   ```terraform init```

## Deployment

1. Review the planned changes:
   `terraform plan`

2. Apply the Terraform configuration:
   `terraform apply`

3. When prompted, type `yes` to confirm the creation of resources.

## Components

### VPC and Networking

- Creates a new VPC with public and private subnets
- Sets up Internet Gateway and NAT Gateways
- Configures route tables for public and private subnets

### EKS Cluster

- Deploys an EKS cluster with worker nodes in private subnets
- Configures cluster IAM roles and security groups

### Helm Charts

#### Apache Kafka

- Installs Kafka using Bitnami's Helm chart
- Configures replication factor, number of brokers, and Zookeeper settings

#### PostgreSQL

- Deploys PostgreSQL database using Bitnami's Helm chart
- Sets up database name, username, and password

#### Cluster Autoscaler

- Installs Cluster Autoscaler for automatic scaling of worker nodes
- Configures necessary IAM roles and permissions

## Accessing the Cluster

After successful deployment, configure kubectl to interact with your cluster:

```
aws eks get-token --cluster-name <your-cluster-name> | kubectl apply -f -
```

## Cleanup

To destroy all created resources:

```
terraform destroy
```

When prompted, type `yes` to confirm the deletion of resources.

## Notes

- Ensure that your AWS credentials have the necessary permissions to create and manage EKS clusters and related resources.
- The Kafka and PostgreSQL services are deployed with default configurations. Modify the Helm chart values in `helm.tf` for production-ready settings.
- Cluster Autoscaler is configured to work with the EKS cluster's autoscaling group. Adjust the IAM permissions if needed.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.