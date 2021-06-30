// credentials

// aws credentials
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

// digitalocean credentials
variable "aws_ssm_parameter__digitalocean_token" {
  default     = "/provider/digitalocean/TOKEN"
  description = "This is vendor-specific - for digitalocean. In order to retrieve the K8 cluster on digitalocean, you need a valid digitalocean account token"
}

// docker credentials
variable "aws_ssm_parameter__docker_email" {
  default = "/provider/dockerhub/DOCKERHUB_EMAIL"
  type    = string
}
variable "aws_ssm_parameter__docker_username" {
  default = "/provider/dockerhub/DOCKERHUB_USERNAME"
  type    = string
}
variable "aws_ssm_parameter__docker_password" {
  default = "/provider/dockerhub/DOCKERHUB_PASSWORD"
  type    = string
}


// variable inputs

variable "cluster_name" {
  description = "The name of the Kubernetes cluster to deploy microservice on. This is a generic property, not a vendor-specific one."
}

variable "node_pool_name" {
  description = "The name of a node pool that you'd like the deployment to provision pods on"
  type = string
  default = ""
}

variable "scale" {
  description = "The number of replica"
  type = number
  default = 1
}

variable "app_label" {
  description = "A label for the microservice that will be used to prefix and suffix resources"
}

variable "app_exposed_port" {
  description = "Unique port within Kubernetes cluster for ingress to direct external traffic to the microservice"
}

variable "additional_exposed_ports" {
  description = "Unique ports within Kubernetes cluster for internal traffic routing to the microservice. Note that this is not for external traffic - for such case please use `app_exposed_port` instead"
  type = list
  default = []
}

variable "app_container_image" {
  description = "The container image name without tag"
}

variable "app_container_image_tag" {
  description = "The image tag to use, usually this somes from a hash tag associate with a git commit or CI/CD build"
}

variable "app_secret_name_list" {
  description = "A list that the microservice will use in runtime"
  type        = list
  default     = []
}

variable "app_deployed_domain" {
  description = "The exact domain name to deploy the microservice on"
  default     = ""
}

variable "cors_domain_whitelist" {
  description = "Allows restricted methods like POST to be sent to the microservice from the domains in the whiltelist, usually this means the frontend site that talks to the microservice."
  default     = []
  type        = list
}

variable "kubernetes_cron_jobs" {
  default = []
  type    = list
}

variable "persistent_volume_mount_setting_list" {
  default = []
  type    = list(object({
    mount_path_secret_name = string
    size = string # e.g. 1Gi
  }))
}

variable "share_host_memory" {
  description = "Share host memory by using host mount path on `/dev/shm`, useful when running containers that require a larger startup memory (default is 64M), e.g. selenium webdriver"
  default = false
  type = bool
}

variable "memory_max_allowed" {
  description = "Set memory limit on deployment. Needs to be used with `memory_guaranteed` otherwise no effect."
  default = "512Mi"
  type = string
}

variable "memory_guaranteed" {
  description = "Set memory guarantee on deployment. Needs to be used with `memory_max_allowed` otherwise no effect."
  default = "256Mi"
  type = string
}

variable "enable_docker_socket" {
  description = "This will mount docker socket so that the container have access to docker engine. Note: you still have to install docker client in the pod / image. This assumes the kubernetes provider uses docker as container engine - which may not always be the case, there're other types of containerization tool. If the k8s provider does not use docker, this monuting will fail."
  default = false
  type = bool
}

variable "environment_variables" {
  default = {}
  type    = map
}

variable "depend_on" {
  default = []
  type    = list
}

variable "docker_registry_url" {
  default = "https://index.docker.io/v1/"
  type    = string
}

variable "use_recreate_deployment_strategy" {
  default = false
  type = bool
}
