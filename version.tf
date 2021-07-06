terraform {
  # please use tfenv if you're not in this version interval
  # note that tfstate is binded with tf version
  # so be sure to use the specified version whenever possible
  required_version  = "<=2.0.0, >= 1.0.1"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "<= 3.0.0, >= 2.0"
    }
  }
}
