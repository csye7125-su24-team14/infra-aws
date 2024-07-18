resource "helm_release" "kafka" {
  depends_on = [kubernetes_namespace.kafka]
  name       = "my-kafka"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  # repository          = "https://github.com/csye7125-su24-team14/helm-charts.git"
  chart               = "kafka"
  repository_username = var.github_username
  repository_password = var.github_password
  namespace           = kubernetes_namespace.kafka.metadata[0].name
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


resource "helm_release" "autoscaler" {
  depends_on = [kubernetes_namespace.autoscaler]
  name       = "autoscaler"
  # repository = "https://kubernetes.github.io/autoscaler" 
  repository = "https://github.com/csye7125-su24-team14/helm-eks-autoscaler.git"

  chart               = "helm-eks-autoscaler"
  repository_username = var.github_username
  repository_password = var.github_password
  namespace           = kubernetes_namespace.autoscaler.metadata[0].name
  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "autoDiscovery.namespace"
    value = kubernetes_namespace.autoscaler.metadata[0].name
  }


}



resource "helm_release" "postgres" {
  depends_on = [kubernetes_namespace.postgres]
  name       = "my-postgres"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  # repository = "https://github.com/nandreanurag/helm-chart-test"
  chart = "postgresql"
  # repository_username = var.github_username
  # repository_password = var.github_password
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
