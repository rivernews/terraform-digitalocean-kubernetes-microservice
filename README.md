# Microservice for Kubernetes

Terraform module that provisions a microservice on an existing Kubernetes cluster.

## Prerequisites

### Digitalocean
This module currently assumes the use of Digitalocean Kubernetes Service. However, you may easily change your favored kubernetes vendor by forking this repo **and modify the content of `kubernetes-cluster.tf`**.

### A running Kubernetes cluster
Regradless of which Kubernetes vendor you use, this terraform module assumes you provisioned a Kubernetes cluster already - so this means that you are required to have an existing K8 cluster, or at least terraform scripts that provision them. If you're not using digitalocean as your K8 cluster provider and using other kubernetes cluster vendor, you will modify `kubernetes-cluster.tf`, so that `local_file.kubeconfig` will generate the right `kubeconfig.yaml`.

### AWS - credential management using AWS parameter store
This module assumes you use AWS parameter store for credential management. As such, you will have to provide your AWS account credentials through the three variable inputs: 

```
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
```

This module assumes you have the following credentials created in your AWS parameter store. You may go into your AWS portal and create the following keys and their values:
```terraform
variable "aws_ssm_parameter__digitalocean_token" {
  default     = "/provider/digitalocean/TOKEN" # the key you store your credential in AWS parameter store
  description = "This is vendor-specific - for digitalocean. In order to retrieve the K8 cluster on digitalocean, you need a valid digitalocean account token. You can retrieve this toke in digitalocean account portal."
}
```

The following credentials are only required if your microservice uses a docker image whose registry is private.
```terraform
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
```

### Ingress controller and externalDns resource running on your K8
Lastly, if your microservice needs to be exposed to external traffic & be assigned a domain name, this module assumes your cluster already have ingress controller and externalDns resource configured. **Particularly, your ingress controller has a `default-ssl-certificate` configured w/ wildcard certificate**, which can be used to deploy microservice to your desired subdomain (covered by the wildcard certificate). You can specify your desired domain name for the microservice by variable `app_deployed_domain`. If your microservice does not need to be accessed outside from the cluster, then ingress controller and externalDns are not required. You can ignore the variable `app_deployed_domain` in such case.

## How to use

An example of using this terraform module:

```terraform

module "slack_middleware_service" {
  source  = "rivernews/kubernetes-microservice/digitalocean"
  version = "0.0.1"
  
  # credential management
  aws_region     = "${You will have to provide this}"
  aws_access_key = "${You will have to provide this}"
  aws_secret_key = "${You will have to provide this}"
  
  # cluster-wise config (shared resources across different microservices)
  cluster_name = "${YOUR_CLUSTER_NAME_NEEDS_TO_BE_HERE}"

  # app-specific config (microservice)
  
  # this label will be added and used as prefix to related resources
  app_label               = "slack-middleware-service"
  
  # we assume your ingress controller use `ClusterIP` mode, so make sure there aren't any service using this port within your kubernetes cluster
  app_exposed_port        = 8002

  # (optional) if you want your microservice to be accessed from externa traffic by `https` connection, 
  # specify a domain name that is covered by your wilcard certificate.
  # also make sure you have externalDns resource to provision the new domain name for you.
  # In case you don't have a certificate, if your ingress resource does not 
  # force or redirect to ssl, you can still use it will `http` connection
  app_deployed_domain     = "slack.api.shaungc.com"

  # (optional) if you provide any in the whitelist, they will be joined
  # by a comma, and serve as environment variable `CORS_DOMAIN_WHITELIST`
  cors_domain_whitelist   = []
  
  # the docker image your microservice will be spinning up
  app_container_image     = "shaungc/slack-middleware-service"

  # tag of your docker image, e.g., `latest`, etc.
  app_container_image_tag = var.slack_middleware_service_image_tag

  # (optional) a list of AWS parameter store keys that contains credentials or constants
  # they will be served as environment variable into your microservice container
  # note that only the string after the last slask `/` will be used as environment variable name
  # e.g. "/app/slack-middleware-service/NODE_ENV" --> NODE_ENV
  app_secret_name_list = [
    "/app/slack-middleware-service/NODE_ENV",
    "/app/slack-middleware-service/HOST",
    "/app/slack-middleware-service/PORT",
    "/app/slack-middleware-service/SLACK_TOKEN_OUTGOING_LAUNCH",
    "/app/slack-middleware-service/SLACK_TOKEN_OUTGOING_LIST_ORG",
    "/app/slack-middleware-service/SLACK_TOKEN_INCOMING_URL",
    "/app/slack-middleware-service/TRAVIS_TOKEN"
  ]
  
  # (optional) you can also pass in addtional environment variables to the microservice
  # container in runtime:
  environment_variables = {
    ELASTICSEARCH_PORT = local.elasticsearch_port
  }
  
  # (optional) you can also specify cronjob that will be scheduled alongside
  # with your microservice, e.g., backup db job, or other maintenance work
  kubernetes_cron_jobs = [
    {
      name          = "db-backup-cronjob",
      cron_schedule = "0 6 * * *",
      command = ["/bin/sh", "-c", "echo Starting cron job... && sleep 5 && cd /usr/src/backend && echo Finish CD && python manage.py backup_db && echo Finish dj command"]
    },
  ]
  
  # (optional) you may use this to signal terraform to be aware of dependencies
  # so that resources are created in your desired order
  depend_on = [
      module.postgres_cluster.app_container_image
  ]
}

```

## Reference

This repository is also [published on the Terraform Registry](https://registry.terraform.io/modules/rivernews/kubernetes-microservice/).