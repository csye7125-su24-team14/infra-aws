resource "helm_release" "kafka" {
  depends_on = [kubernetes_namespace.kafka]
  name       = "my-kafka"
  chart      = "helm-charts/kafka"
  namespace  = kubernetes_namespace.kafka.metadata[0].name

  values = [
    templatefile("helm-charts/kafka/values.yaml", {
      kafka_password = var.kafka_password
      kafka_username = var.kafka_username
    })
  ]
}

resource "helm_release" "postgres" {
  depends_on = [kubernetes_namespace.postgres]
  name       = "my-postgres"
  chart      = "helm-charts/postgresql"
  namespace  = kubernetes_namespace.postgres.metadata[0].name

  values = [
    templatefile("helm-charts/postgresql/values.yaml", {
      postgres_username = var.postgres_username
      postgres_password = var.postgres_password
      postgres_database = var.postgres_database
      PGDUMP_DIR        = "/tmp"
    })
  ]
}