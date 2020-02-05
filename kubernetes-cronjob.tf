# tf spec: https://www.terraform.io/docs/providers/kubernetes/r/cron_job.html
# k8 spec: https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/
resource "kubernetes_cron_job" "simple_cmd_job" {
  count = length(var.kubernetes_cron_jobs)

  metadata {
    name      = "${var.app_label}-${var.kubernetes_cron_jobs[count.index]["name"]}-cronjob"
    namespace = kubernetes_service_account.app.metadata.0.namespace
  }
  spec {
    concurrency_policy            = "Replace"
    failed_jobs_history_limit     = 10
    successful_jobs_history_limit = 5
    schedule                      = var.kubernetes_cron_jobs[count.index]["cron_schedule"]
    starting_deadline_seconds     = 5

    job_template {
      # metadata block is required
      metadata {}

      spec {

        # https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/#job-termination-and-cleanup
        active_deadline_seconds = 60 # max job alive time

        # https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/#pod-backoff-failure-policy
        backoff_limit = 2 # 1 retry (at pod-recreation level)

        template {
          # metadata block is required
          metadata {}

          spec {
            container {
              name    = "${var.app_label}-${var.kubernetes_cron_jobs[count.index]["name"]}-cronjob-container"
              image   = lower(trimspace("${var.app_container_image}:${var.app_container_image_tag}"))
              command = var.kubernetes_cron_jobs[count.index]["command"]

              env_from {
                secret_ref {
                  name = kubernetes_secret.app_credentials.metadata.0.name
                }
              }

              env {
                name  = "DEPLOYED_DOMAIN"
                value = var.app_deployed_domain
              }
              env {
                name  = "CORS_DOMAIN_WHITELIST"
                value = join(",", var.cors_domain_whitelist)
              }
            }

            # tf doc: https://www.terraform.io/docs/providers/kubernetes/r/deployment.html#template-spec
            restart_policy = "Never"
          }
        }
      }
    }
  }
}
