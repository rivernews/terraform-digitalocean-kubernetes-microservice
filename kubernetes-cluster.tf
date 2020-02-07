data "aws_ssm_parameter" "digitalocean_token" {
  name = var.aws_ssm_parameter__digitalocean_token
}

provider "digitalocean" {
  token   = data.aws_ssm_parameter.digitalocean_token.value

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
    # filename = "${path.module}/kubeconfig.yaml"
    filename = "kubeconfig.yaml"
}


provider "kubernetes" {
  # all k8 provider versions: https://github.com/terraform-providers/terraform-provider-kubernetes/blob/master/CHANGELOG.md
  version = "~> 1.9"

  host = data.digitalocean_kubernetes_cluster.for_app.endpoint

  token = data.digitalocean_kubernetes_cluster.for_app.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.for_app.kube_config[0].cluster_ca_certificate
  )
  
  # adding this block to resolve tf error: `<a k8 resource> is forbidden: User "system:anonymous cannot create resource "<a k8 resource>" in API group "" at the cluster scope`
  client_certificate     = data.digitalocean_kubernetes_cluster.for_app.kube_config[0].client_certificate
  client_key             = data.digitalocean_kubernetes_cluster.for_app.kube_config[0].client_key
  
}