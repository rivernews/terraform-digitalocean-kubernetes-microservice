data "aws_ssm_parameter" "digitalocean_token" {
  name = var.aws_ssm_parameter__digitalocean_token
}

data "digitalocean_kubernetes_cluster" "for_app" {
    name = var.cluster_name
}

provider "kubernetes" {
  # Resolve Error: Unauthorized issue
  # suggested config: https://stackoverflow.com/a/58955100/9814131
  # suggested cli: https://github.com/terraform-providers/terraform-provider-kubernetes/issues/679#issuecomment-552119320
  # related merge request: https://github.com/terraform-providers/terraform-provider-kubernetes/pull/690

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
