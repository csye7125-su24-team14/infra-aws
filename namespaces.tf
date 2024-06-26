//multiple kubernetes_namespace resource
resource "kubernetes_namespace" "webapp_producer" {
  depends_on = [null_resource.wait_for_cluster_ready]
  metadata {
    name = "webapp-producer"
  }
}

resource "kubernetes_namespace" "webapp_consumer" {
  depends_on = [null_resource.wait_for_cluster_ready]
  metadata {
    name = "webapp-consumer"
  }
}

resource "kubernetes_namespace" "postgres" {
  depends_on = [null_resource.wait_for_cluster_ready]
  metadata {
    name = "postgres"
  }
}

resource "kubernetes_namespace" "kafka" {
  depends_on = [null_resource.wait_for_cluster_ready]
  metadata {
    name = "kafka"
  }
}
