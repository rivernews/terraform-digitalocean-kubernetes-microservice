resource "kubernetes_namespace" "app" {
  metadata {
    # tf: `name` cannot be updated after created
    name = var.app_label

    labels = {
        app = var.app_label
    }
  }
}