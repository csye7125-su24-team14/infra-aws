resource "helm_release" "kafka" {
  depends_on = [kubernetes_namespace.kafka]
  name       = "my-kafka"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "kafka"
  namespace  = kubernetes_namespace.kafka.metadata[0].name
  set {
    name  = "sasl.client.users[0]"
    value = var.kafka_username
  }

  set {
    name  = "sasl.client.passwords[0]"
    value = var.kafka_password
  }

  set {
    name  = "controller.resourcesPreset"
    value = "medium"
  }
}



resource "helm_release" "postgres" {
  depends_on = [kubernetes_namespace.postgres]
  name       = "my-postgres"
  # repository = "oci://registry-1.docker.io/bitnamicharts"
  chart = "https://x-access-token:${var.github_token}@github.com/${var.github_orgname}/${var.github_postgres_repo}/archive/refs/tags/v${local.latest_postgres_version}.tar.gz"
  # https://github.com/csye7125-su24-team14/helm-postgresql/archive/refs/tags/v1.0.0.tar.gz
  # chart      = "postgresql"
  namespace = kubernetes_namespace.postgres.metadata[0].name

  set {
    name  = "global.postgresql.auth.username"
    value = var.postgres_username
  }
  set {
    name  = "global.postgresql.auth.postgresqlPassword"
    value = var.postgres_password
  }
  set {
    name  = "global.postgresql.auth.password"
    value = var.postgres_password
  }
  set {
    name  = "global.postgresql.auth.database"
    value = var.postgres_database
  }
  set {
    name  = "primary.resourcesPreset"
    value = "small"
  }
  set {
    name  = "primary.networkPolicy.enabled"
    value = "false"
  }
}

data "http" "latest_autoscaler_release" {
  url = "https://api.github.com/repos/${var.github_orgname}/${var.github_autoscaler_repo}/releases/latest"

  request_headers = {
    Accept        = "application/vnd.github.v3+json"
    Authorization = "token ${var.github_token}"
  }
}

data "http" "latest_postgres_release" {
  url = "https://api.github.com/repos/${var.github_orgname}/${var.github_postgres_repo}/releases/latest"

  request_headers = {
    Accept        = "application/vnd.github.v3+json"
    Authorization = "token ${var.github_token}"
  }
}

locals {
  latest_autoscaler_release = jsondecode(data.http.latest_autoscaler_release.response_body)
  latest_autoscaler_version = trimprefix(local.latest_autoscaler_release.tag_name, "v")
  latest_postgres_release   = jsondecode(data.http.latest_postgres_release.response_body)
  latest_postgres_version   = trimprefix(local.latest_postgres_release.tag_name, "v")
}

resource "helm_release" "autoscaler" {
  depends_on = [kubernetes_namespace.autoscaler]
  name       = "cluster-autoscaler"
  chart      = "https://x-access-token:${var.github_token}@github.com/${var.github_orgname}/${var.github_autoscaler_repo}/archive/refs/tags/v${local.latest_autoscaler_version}.tar.gz"
  namespace  = kubernetes_namespace.autoscaler.metadata[0].name

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }
  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }
  set {
    name  = "cloudProvider"
    value = "aws"
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cluster_autoscaler.arn
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

}