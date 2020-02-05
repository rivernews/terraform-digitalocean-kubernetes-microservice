data "aws_ssm_parameter" "docker_email" {
  name = "/provider/dockerhub/DOCKERHUB_EMAIL"
}

data "aws_ssm_parameter" "docker_username" {
  name = "/provider/dockerhub/DOCKERHUB_USERNAME"
}

data "aws_ssm_parameter" "docker_password" {
  name = "/provider/dockerhub/DOCKERHUB_PASSWORD"
}

locals {
    dockercfg = {
        auths = {
            "${var.docker_registry_url}" = {
                email    = data.aws_ssm_parameter.docker_email.value
                username = data.aws_ssm_parameter.docker_username.value
                password = data.aws_ssm_parameter.docker_password.value
                auth = base64encode(format("%s:%s", data.aws_ssm_parameter.docker_username.value, data.aws_ssm_parameter.docker_password.value))
            }
        }
    }
}

# TODO: you may publish iriversland-api's image and remove dockerhub_secret
# since most of our docker image are public
# k8 official doc on dockerconfigjson: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line
# terraform doc: https://www.terraform.io/docs/providers/kubernetes/r/secret.html
# only for iriversland2 (secret only available in same namespace)
resource "kubernetes_secret" "dockerhub_secret" {
  metadata {
    name = "${var.app_label}-dockerhub-secret"
    namespace = kubernetes_namespace.app.metadata.0.name
  }

  data = {
    ".dockerconfigjson" = jsonencode(local.dockercfg)
  }

  type = "kubernetes.io/dockerconfigjson"
}
