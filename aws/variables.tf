###############################################################################
# VARIABLES 
###############################################################################

variable "region" {
  default = "eu-west-2" # London
}

variable "access_key" {}

variable "secret_key" {}

variable "rancher_bucket_name" {
  default = "morsley-io-rancher"
}

variable "kube_config_filename" {
  default = "morsley-io-kube-config.yaml"
}

# ToDo --> use throughout
variable "cluster_name" {
  default = "morsley-io"
}

variable "hostname" {
  default = "rancher.morsley.io"
}