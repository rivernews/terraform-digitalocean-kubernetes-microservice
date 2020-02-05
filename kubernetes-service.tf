resource "kubernetes_service" "app" {
  metadata {
    name      = "${var.app_label}-service"
    namespace = kubernetes_service_account.app.metadata.0.namespace
    labels = {
      app = var.app_label
    }
  }
  spec {
    type = "ClusterIP"

    selector = {
      app = var.app_label
    }

    port {
      #    name = "http"
      #    protocol    = "TCP"

      # make this service visible to other services by this port; https://stackoverflow.com/a/49982009/9814131
      port        = var.app_exposed_port 

      # the port where your application is running on the container
      target_port = var.app_exposed_port
    }
  }
}
