provider "digitalocean" {
  token   = data.aws_ssm_parameter.digitalocean_token.value
}
