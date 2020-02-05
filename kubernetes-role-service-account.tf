# service account for deploying app (cicd, e.g. circleci)
#
#
resource "kubernetes_service_account" "app" {
    # https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
#   automount_service_account_token = true

  metadata {

    name      = "${var.app_label}-service-account"
    namespace = kubernetes_namespace.app.metadata.0.name
    # namespace =  "cert-manager" # TODO: after being able to let microservice use their own namespace, change this line to use module input values
  }

}


resource "kubernetes_role" "app" {
  metadata {
    name      = "${var.app_label}-role"
    namespace = kubernetes_service_account.app.metadata.0.namespace
  }

  rule {
    api_groups = ["", "apps", "batch", "extensions"]
    resources  = ["deployments", "services", "replicasets", "pods", "jobs", "cronjobs"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "app" {
  metadata {
    name      = "${var.app_label}-rule"
    namespace = kubernetes_service_account.app.metadata.0.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.app.metadata.0.name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.app.metadata.0.name
    api_group = ""
    namespace = kubernetes_service_account.app.metadata.0.namespace
  }
}
