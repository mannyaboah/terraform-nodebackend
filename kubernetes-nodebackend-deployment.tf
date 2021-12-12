resource "kubernetes_deployment" "nodebackend-deployment" {
  metadata {
    name = "nodebackend-deployment"
    labels = {
      App = "nodebackend"
    }
    namespace = kubernetes_namespace.n.metadata[0].name
  }

  spec {
    replicas                  = 4
    progress_deadline_seconds = 60
    selector {
      match_labels = {
        App = "nodebackend"
      }
    }
    template {
      metadata {
        labels = {
          App = "nodebackend"
        }
      }
      spec {
        container {
          image = "mannyaboah/nodebackend:v0.1"
          name  = "nodebackend"

          env {
            name  = "PORT"
            value = "8082"
          }

          port {
            container_port = 8082
          }

          resources {
            limits = {
              cpu    = "0.2"
              memory = "2562Mi"
            }
            requests = {
              cpu    = "0.1"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}