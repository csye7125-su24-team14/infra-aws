//multiple kubernetes_namespace resource
resource "kubernetes_namespace" "webapp_producer" {
  depends_on = [null_resource.wait_for_cluster_ready]
  metadata {
    name = "webapp-producer"
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_namespace" "webapp_consumer" {
  depends_on = [null_resource.wait_for_cluster_ready]
  metadata {
    name = "webapp-consumer"
    labels = {
      "istio-injection" = "enabled"
    }
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
    labels = {
      "istio-injection" = "enabled"
    }
  }
}

resource "kubernetes_namespace" "autoscaler" {
  depends_on = [null_resource.wait_for_cluster_ready]
  metadata {
    name = "autoscaler"
  }
}

resource "kubernetes_namespace" "amazon-cloudwatch" {
  depends_on = [null_resource.wait_for_cluster_ready]
  metadata {
    name = "amazon-cloudwatch"
  }
}

resource "kubernetes_namespace" "istio-system" {
  depends_on = [null_resource.wait_for_cluster_ready]
  metadata {
    name = "istio-system"
  }
}

resource "kubernetes_namespace" "istio-ingress" {
  depends_on = [null_resource.wait_for_cluster_ready]
  metadata {
    name = "istio-ingress"
  }
}

resource "kubernetes_namespace" "external-dns" {
  depends_on = [null_resource.wait_for_cluster_ready]
  metadata {
    name = "external-dns"
  }
}
