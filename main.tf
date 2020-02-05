provider "local" {
    version = "~> 1.3"
}

resource "local_file" "kubeconfig" {
    sensitive_content     = var.kubeconfig_raw
    filename = "${path.module}/kubeconfig.yaml"
}