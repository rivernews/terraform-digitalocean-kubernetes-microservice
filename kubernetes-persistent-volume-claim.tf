#  the following config is based on digitalocean doc
# https://www.digitalocean.com/docs/kubernetes/how-to/add-volumes/
#
# other cloud provider may have different convention, i.e., needing to create a `kubernetes_persistent_volume` before creating a claim
#
#
# tf doc: https://www.terraform.io/docs/providers/kubernetes/r/persistent_volume_claim.html
resource "kubernetes_persistent_volume_claim" "app_digitalocean_pvc" {
  count = var.persistent_volume_mount_path_secret_name != "" ? 1 : 0

  metadata {
    # for digitalocean - must be lowercase alphanumeric values and dashes (hyphen) only
    name      = count.index == 0 ? "${var.app_label}-persistent-volume-claim" : "${var.app_label}-persistent-volume-claim-${count.index}"
    namespace = kubernetes_service_account.app.metadata.0.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi" # changing the storage value in the resource definition after the volume has been created will have no effect
      }
    }

    storage_class_name = "do-block-storage"
  }

  # no need to delete pvc, tf will clean up for you
#   provisioner "local-exec" {
#     when    = "destroy"
#     command = "kubectl --kubeconfig ${path.module}/kubeconfig.yaml delete pvc -n ${kubernetes_service_account.app.metadata.0.namespace} ${var.app_label}-persistent-volume-claim"
#   }

  depends_on = [
    local_file.kubeconfig
  ]
}
