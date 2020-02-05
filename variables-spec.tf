variable "app_label" {
  description = "A label for the microservice that will be used to prefix and suffix resources"
}

variable "app_exposed_port" {
  description = "Unique port within Kubernetes cluster for ingress to direct external traffix to the microservice"
}

variable "app_container_image" {
  description = "The container image name without tag"
}

variable "app_container_image_tag" {
  description = "The image tag to use, usually this somes from a hash tag associate with a git commit or CI/CD build"
}

variable "app_secret_name_list" {
  description = "A list that the microservice will use in runtime"
  type = list
}

variable "app_deployed_domain" {
  description = "The exact domain name to deploy the microservice on"
  default = ""
}

variable "cors_domain_whitelist" {
    description = "Allows restricted methods like POST to be sent to the microservice from the domains in the whiltelist, usually this means the frontend site that talks to the microservice."
    default = []
    type = list
}

variable "kubernetes_cron_jobs" {
    default = []
    type = list
}

variable "kubeconfig_raw" {
    default = ""
    type = string
}

variable "persistent_volume_mount_path_secret_name" {
    default = ""
    type = string
}

variable "environment_variables" {
    default = {}
    type  = map
}

variable "depend_on" {
    default = []
    type = list
}

variable "docker_registry_url" {
  default = "https://index.docker.io/v1/"
  type = string
}