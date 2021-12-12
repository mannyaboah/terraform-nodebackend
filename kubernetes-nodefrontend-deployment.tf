resource "kubernetes_deployment" "nodefrontend-deployment" {
  metadata {
    name = "nodefrontend-deployment"
    labels = {
      App = "nodefrontend"
    }
    namespace = kubernetes_namespace.n.metadata[0].name
  }

  spec {
    replicas                  = 2
    progress_deadline_seconds = 90
    selector {
      match_labels = {
        App = "nodefrontend"
      }
    }
    template {
      metadata {
        labels = {
          App = "nodefrontend"
        }
      }
      spec {
        container {
          image = "mannyaboah/nodefrontend:v0.1"
          name  = "nodefrontend"

          env {
            name  = "SERVER"
            value = "http://nodebackend-service:8082"
          }

          port {
            container_port = 8080
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