resource "kubernetes_namespace" "n" {
  metadata {
    name = "nodebackend"
  }
}