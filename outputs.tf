output "microservice_deployed_domain" {
  value = var.app_deployed_domain
}
output "microservice_deployed_endpoint" {
  value = "http://${var.app_deployed_domain}"
}

output "microservice_hashed_deployed_domain" {
  value = "${var.app_container_image_tag}.${var.app_deployed_domain}"
}
output "microservice_hashed_deployed_endpoint" {
  value = "http://${var.app_container_image_tag}.${var.app_deployed_domain}"
}

output "microservice_kubernetes_service_name" {
  value = kubernetes_service.app.metadata.0.name
}

output "microservice_kubernetes_service_port" {
  value = var.app_exposed_port
}

output "microservice_namespace" {
  #   value = "${kubernetes_service_account.app.metadata.0.namespace}"
  value = "cert-manager"
}

output "microservice_runtime_env_vars" {
  value = local.app_secret_key_value_pairs
}



# vars
output "app_container_image" {
  value = var.app_container_image
}

output "app_container_image_tag" {
  value = var.app_container_image_tag
}
