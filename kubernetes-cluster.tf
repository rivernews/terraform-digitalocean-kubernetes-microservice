data "aws_ssm_parameter" "digitalocean_token" {
  name = var.aws_ssm_parameter__digitalocean_token
}

provider "digitalocean" {
  token   = var.aws_ssm_parameter__digitalocean_token

  # version changelog: https://github.com/terraform-providers/terraform-provider-digitalocean/blob/master/CHANGELOG.md
  version = "~> 1.11"
}

data "digitalocean_kubernetes_cluster" "for_app" {
    name = var.cluster_name
}

provider "local" {
    version = "~> 1.3"
}

resource "local_file" "kubeconfig" {
    sensitive_content     = data.digitalocean_kubernetes_cluster.for_app.kube_config.0.raw_config
    filename = "${path.module}/kubeconfig.yaml"
}
