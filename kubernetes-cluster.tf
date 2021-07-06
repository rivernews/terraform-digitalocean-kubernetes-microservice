data "aws_ssm_parameter" "digitalocean_token" {
  name = var.aws_ssm_parameter__digitalocean_token
}

data "digitalocean_kubernetes_cluster" "for_app" {
    name = var.cluster_name
}

provider "local" {
    version = "~> 1.3"
}

resource "local_file" "kubeconfig" {
    sensitive_content     = data.digitalocean_kubernetes_cluster.for_app.kube_config.0.raw_config
    # filename = "${path.module}/kubeconfig.yaml"
    filename = "kubeconfig.yaml"
}


provider "kubernetes" {
  # Resolve Error: Unauthorized issue
  # suggested config: https://stackoverflow.com/a/58955100/9814131
  # suggested cli: https://github.com/terraform-providers/terraform-provider-kubernetes/issues/679#issuecomment-552119320
  # related merge request: https://github.com/terraform-providers/terraform-provider-kubernetes/pull/690

  # all k8 provider versions: https://github.com/terraform-providers/terraform-provider-kubernetes/blob/master/CHANGELOG.md
  # make sure you update the tf kubernetes provider version in repo iriversland2-kubernetes as well
  version = "1.13.3"

  host = data.digitalocean_kubernetes_cluster.for_app.endpoint

  load_config_file = false

  token = data.digitalocean_kubernetes_cluster.for_app.kube_config[0].token

  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.for_app.kube_config[0].cluster_ca_certificate
  )

  # adding this block to resolve tf error: `<a k8 resource> is forbidden: User "system:anonymous cannot create resource "<a k8 resource>" in API group "" at the cluster scope`
  # client_certificate     = data.digitalocean_kubernetes_cluster.for_app.kube_config[0].client_certificate
  # client_key             = data.digitalocean_kubernetes_cluster.for_app.kube_config[0].client_key

}
