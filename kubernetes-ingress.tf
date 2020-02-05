locals {
#   app_deployed_domain_hashed = "${var.app_container_image_tag}.${var.app_deployed_domain}"

  deployed_domain_list = [
    # "${local.app_deployed_domain_hashed}",
    var.app_deployed_domain,
  ]
}




# template copied from terraform official doc: https://www.terraform.io/docs/providers/kubernetes/r/ingress.html
# modified based on SO answer: https://stackoverflow.com/a/55968709/9814131
# TODO: change name `project-ingress-resource` to `app`
resource "kubernetes_ingress" "app" {
  count = var.app_deployed_domain != "" ? 1 : 0

  metadata {
    name      = "${var.app_label}-ingress-resource"
    namespace = kubernetes_service.app.metadata.0.namespace

    # annotation spec: https://github.com/kubernetes/ingress-nginx/blob/master/docs/user-guide/nginx-configuration/annotations.md#annotations
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"

      ## annotation `force redirect` only works if you specify the `tls` block below
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "false"

    #   "ingress.kubernetes.io/ssl-redirect" = "false"

      #   "nginx.ingress.kubernetes.io/use-regex" = "true"

      ## annotation `tls-acme`: use it w/ ingress controller's `ingressShim` set
      ## deprecated? It's a kube-lego feature, no effect if you're not using kube-lego: https://kubernetes.github.io/ingress-nginx/user-guide/tls/#automated-certificate-management-with-kube-lego
      # https://docs.cert-manager.io/en/latest/tasks/issuing-certificates/ingress-shim.html#configuration
        # "kubernetes.io/tls-acme"            = "true"

      ## annotation `cluster-issuer` causes cert-manager to create a Certificate resource that matches your ingress
      # https://github.com/jetstack/cert-manager/issues/841#issuecomment-414299467
      #   "certmanager.k8s.io/cluster-issuer" = "${var.cert_cluster_issuer_name}"
    }
  }

  spec {

    ## adding `tls` block to let ingress controller to secure this ingress (allow 443), but possibly will make http unavailable
    # https://github.com/kubernetes/ingress-nginx/issues/3235#issuecomment-429573596
    # https://github.com/jetstack/cert-manager/issues/841#issuecomment-414299467
    tls {
    #   hosts       = var.tls_cert_covered_domain_list
      hosts       = local.deployed_domain_list

      # not specifying a secret name will let the k8 cluster's ingress controller 
      # use default-ssl-certificate, if it is configured
    #   secret_name = var.cert_cluster_issuer_k8_secret_name
    }

    # do not put this same tls in other ingress resources spec
    # if you want to share the tls domain, just place tls in one of the ingress resource
    # see https://github.com/jetstack/cert-manager/issues/841#issuecomment-414299467

    dynamic "rule" {
      for_each = local.deployed_domain_list
      content {
        host = rule.value
        http {
          path {
            backend {
              service_name = kubernetes_service.app.metadata.0.name
              service_port = var.app_exposed_port
            }

            path = "/"
          }
        }
      }
    }
  }

  depends_on = [
    # do not run cert-manager before creating this ingress resource
    # ingress resource must be created first
    # see "4. Create ingress with tls-acme annotation and tls spec":
    # https://medium.com/asl19-developers/use-lets-encrypt-cert-manager-and-external-dns-to-publish-your-kubernetes-apps-to-your-website-ff31e4e3badf
    # DON't -> "helm_release.project-cert-manager",
  ]
}
