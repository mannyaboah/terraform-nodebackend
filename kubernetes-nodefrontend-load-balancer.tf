resource "kubernetes_service" "nodefrontend-service" {
  metadata {
    name      = "nodefrontend-service"
    namespace = kubernetes_namespace.n.metadata[0].name
  }
  spec {
    selector = {
      App = kubernetes_deployment.nodefrontend-deployment.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.nodefrontend-service.status.0.load_balancer.0.ingress.0.ip
}
output "lb_status" {
  value = kubernetes_service.nodefrontend-service.status
}

