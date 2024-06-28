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
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.postgres.metadata[0].name

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
}
