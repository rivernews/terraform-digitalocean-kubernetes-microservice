
# terraform doc: https://www.terraform.io/docs/providers/kubernetes/r/deployment.html
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "${var.app_label}-deployment"
    namespace = kubernetes_service_account.app.metadata.0.namespace
    labels = {
      app = var.app_label
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = var.app_label
      }
    }

    template {
      metadata {
        labels = {
          app = var.app_label
        }
      }

      spec {
        # automount_service_account_token = true

        service_account_name = kubernetes_service_account.app.metadata.0.name

        image_pull_secrets {
          name = kubernetes_secret.dockerhub_secret.metadata.0.name
        }

        container {
          name  = var.app_label
          image = lower(trimspace("${var.app_container_image}:${var.app_container_image_tag}"))

          # terraform official doc: https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#image_pull_policy
          # private image registry: https://stackoverflow.com/questions/49639280/kubernetes-cannot-pull-image-from-private-docker-image-repository
          image_pull_policy = "Always"

          port {
            container_port = var.app_exposed_port
            # name = "http"
          }

          #   dynamic "env" {
          #     for_each = "${local.app_secret_key_value_pairs}"
          #     content {
          #       name  = "${env.key}"
          #       value = "${env.value}"
          #     }
          #   }

          dynamic "env" {
              for_each = var.environment_variables
              content {
                  name  = env.key
                  value = env.value
              }
          }

          # see `env_from` example at: https://www.michielsikkes.com/managing-and-deploying-app-secrets-at-firmhouse/
          env_from {
            secret_ref {
              name = kubernetes_secret.app_credentials.metadata.0.name
            }
          }

          env {
            name  = "DEPLOYED_DOMAIN"
            value = var.app_deployed_domain
          }

          env {
              name = "CORS_DOMAIN_WHITELIST"
              value = join(",", var.cors_domain_whitelist)
          }

          #   resources {
          #     limits {
          #       cpu    = "0.5"
          #       memory = "512Mi"
          #     }
          #     requests {
          #       cpu    = "250m"
          #       memory = "50Mi"
          #     }
          #   }

          #   liveness_probe {
          #     http_get {
          #       path = "/nginx_status"
          #       port = 80

          #       http_header {
          #         name  = "X-Custom-Header"
          #         value = "Awesome"
          #       }
          #     }

          #     initial_delay_seconds = 3
          #     period_seconds        = 3
          #   }
        }
        
        # persistent volume setup
        # based on https://www.digitalocean.com/docs/kubernetes/how-to/add-volumes/
        dynamic "init_container" {
            for_each = data.aws_ssm_parameter.persistent_volume_mount_path
            content {
                name = "${var.app_label}-initial-container-${init_container.key}"
                image = "busybox"
                command = ["/bin/chmod","-R","777", init_container.value.value]
                volume_mount {
                    name = init_container.key == 0 ? "${var.app_label}-volume" : "${var.app_label}-volume-${init_container.key}"
                    mount_path = init_container.value.value
                }
            }
        }

        dynamic "volume" {
            for_each = data.aws_ssm_parameter.persistent_volume_mount_path
            content {
                name = volume.key == 0 ? "${var.app_label}-volume" : "${var.app_label}-volume-${volume.key}"
                persistent_volume_claim {
                    claim_name = kubernetes_persistent_volume_claim.app_digitalocean_pvc[volume.key].metadata.0.name
                }
            }
        }


      }
    }
  }
}


locals {
  app_secret_name_list = var.app_secret_name_list

  app_secret_value_list = data.aws_ssm_parameter.app_credentials.*.value

  app_secret_key_value_pairs = {
    for index, secret_name in local.app_secret_name_list : split("/", secret_name)[length(split("/", secret_name)) - 1] => local.app_secret_value_list[index]
  }
}

data "aws_ssm_parameter" "persistent_volume_mount_path" {
  count = var.persistent_volume_mount_path_secret_name != "" ? 1 : 0
  name = var.persistent_volume_mount_path_secret_name
}

data "aws_ssm_parameter" "app_credentials" {
  count = length(local.app_secret_name_list)
  name  = local.app_secret_name_list[count.index]
}

# terraform doc: https://www.terraform.io/docs/providers/kubernetes/r/secret.html
resource "kubernetes_secret" "app_credentials" {
  metadata {
    name      = "${var.app_label}-credentials"
    namespace = kubernetes_service_account.app.metadata.0.namespace
  }
  # k8 doc: https://github.com/kubernetes/community/blob/c7151dd8dd7e487e96e5ce34c6a416bb3b037609/contributors/design-proposals/auth/secrets.md#secret-api-resource
  # default type is opaque, which represents arbitrary user-owned data.
  type = "Opaque"

  data = local.app_secret_key_value_pairs
}
