#  the following config is based on digitalocean doc
# https://www.digitalocean.com/docs/kubernetes/how-to/add-volumes/
#
# other cloud provider may have different convention, i.e., needing to create a `kubernetes_persistent_volume` before creating a claim
#
#
# tf doc: https://www.terraform.io/docs/providers/kubernetes/r/persistent_volume_claim.html
resource "kubernetes_persistent_volume_claim" "app_digitalocean_pvc" {
  count = length(var.persistent_volume_mount_setting_list)

  metadata {
    # for digitalocean - must be lowercase alphanumeric values and dashes (hyphen) only
    name      = count.index == 0 ? "${var.app_label}-persistent-volume-claim" : "${var.app_label}-persistent-volume-claim-${count.index}"
    namespace = kubernetes_service_account.app.metadata.0.namespace
  }
  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        # Changing the storage value in the resource definition after the volume has been created will have no effect
        # To expand the volume (cannot decrease volume size), you can run something like:
        # `kubectl patch pvc code-server-persistent-volume-claim -p '{ "spec": { "resources": { "requests": { "storage": "4Gi" }}}}' --namespace code-server`
        # See details:
        # https://docs.digitalocean.com/products/kubernetes/how-to/add-volumes/
        storage = var.persistent_volume_mount_setting_list[count.index].size
      }
    }

    storage_class_name = "do-block-storage"
  }

}
