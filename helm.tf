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

  set {
    name  = "metrics.enabled"
    value = "true"
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
data "http" "latest_cve_operator_release" {
  url = "https://api.github.com/repos/${var.github_orgname}/helm-cve-operator/releases/latest"
  request_headers = {
    Accept        = "application/vnd.github.v3+json"
    Authorization = "token ${var.github_token}"
  }
}

data "http" "latest_helm_fluent_bit_release" {
  url = "https://api.github.com/repos/${var.github_orgname}/helm-fluent-bit/releases/latest"
  request_headers = {
    Accept        = "application/vnd.github.v3+json"
    Authorization = "token ${var.github_token}"
  }
}

data "http" "latest_helm_istiod_release" {
  url = "https://api.github.com/repos/${var.github_orgname}/helm-istio-istiod/releases/latest"
  request_headers = {
    Accept        = "application/vnd.github.v3+json"
    Authorization = "token ${var.github_token}"
  }
}
data "http" "latest_helm_istio_base_release" {
  url = "https://api.github.com/repos/${var.github_orgname}/helm-istio-base/releases/latest"
  request_headers = {
    Accept        = "application/vnd.github.v3+json"
    Authorization = "token ${var.github_token}"
  }
}
locals {
  latest_autoscaler_release      = jsondecode(data.http.latest_autoscaler_release.response_body)
  latest_autoscaler_version      = trimprefix(local.latest_autoscaler_release.tag_name, "v")
  latest_postgres_release        = jsondecode(data.http.latest_postgres_release.response_body)
  latest_postgres_version        = trimprefix(local.latest_postgres_release.tag_name, "v")
  latest_cve_operator_release    = jsondecode(data.http.latest_cve_operator_release.response_body)
  latest_cve_operator_version    = trimprefix(local.latest_cve_operator_release.tag_name, "v")
  latest_helm_fluent_bit_release = jsondecode(data.http.latest_helm_fluent_bit_release.response_body)
  latest_helm_fluent_bit_version = trimprefix(local.latest_helm_fluent_bit_release.tag_name, "v")
  latest_helm_istiod_release     = jsondecode(data.http.latest_helm_fluent_bit_release.response_body)
  latest_helm_istiod_version     = trimprefix(local.latest_helm_istiod_release.tag_name, "v")
  latest_helm_istio_base_release = jsondecode(data.http.latest_helm_fluent_bit_release.response_body)
  latest_helm_istio_base_version = trimprefix(local.latest_helm_istio_base_release.tag_name, "v")
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
  set {
    name  = "dockerconfigjson"
    value = data.aws_secretsmanager_secret_version.docker_config_token.secret_string
  }
  set {
    name  = "image.repository"
    value = "anuragnandre/eks-cluster-autoscaler"
  }
  set {
    name  = "image.tag"
    value = "v1.30.0"
  }
}
resource "helm_release" "cve-operator" {
  depends_on = [kubernetes_namespace.webapp_producer]
  name       = "cve-operator"
  chart      = "https://x-access-token:${var.github_token}@github.com/${var.github_orgname}/helm-cve-operator/archive/refs/tags/v${local.latest_cve_operator_version}.tar.gz"
  namespace  = kubernetes_namespace.webapp_producer.metadata[0].name

}

resource "helm_release" "fluent-bit" {
  depends_on = [kubernetes_namespace.amazon-cloudwatch]
  name       = "fluent-bit"
  chart      = "https://x-access-token:${var.github_token}@github.com/${var.github_orgname}/helm-fluent-bit/archive/refs/tags/v${local.latest_helm_fluent_bit_version}.tar.gz"
  namespace  = kubernetes_namespace.amazon-cloudwatch.metadata[0].name

}


resource "helm_release" "istiod" {
  depends_on = [kubernetes_namespace.istio-system]
  name       = "istiod"
  chart      = "https://x-access-token:${var.github_token}@github.com/${var.github_orgname}/helm-istio-istiod/archive/refs/tags/v${local.latest_helm_istiod_version}.tar.gz"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name

}
resource "helm_release" "istio-base" {
  depends_on = [kubernetes_namespace.istio-system]
  name       = "istio-base"
  chart      = "https://x-access-token:${var.github_token}@github.com/${var.github_orgname}/helm-istio-base/archive/refs/tags/v${local.latest_helm_istio_base_version}.tar.gz"
  namespace  = kubernetes_namespace.istio-system.metadata[0].name

}

resource "helm_release" "istio-ingress" {
  depends_on = [kubernetes_namespace.istio-ingress]
  name       = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = kubernetes_namespace.istio-ingress.metadata[0].name

}