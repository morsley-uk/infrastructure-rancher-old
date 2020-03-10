#######################################################################################################################
# RANCHER
#######################################################################################################################

//data "aws_s3_bucket_object" "kube-config-yaml" {
//
//  bucket = var.rancher_bucket_name
//  key    = var.kube_config_filename
//
//}
//
//resource "local_file" "kube-config-yaml" {
//  
//  depends_on = [ data.aws_s3_bucket_object.kube-config-yaml ]
//
//  filename = "rancher/${var.kube_config_filename}"
//  content  = data.aws_s3_bucket_object.kube-config-yaml.body
//  
//}

# https://www.terraform.io/docs/providers/kubernetes/index.html

provider "kubernetes" {

  load_config_file       = true
  #config_path            = "rancher/${var.kube_config_filename}"
  #config_context_cluster = var.cluster_name

}

# -----------------------
# Cert-Manager - JetStack
# -----------------------

# Jetstack - Kubernetes --> https://cert-manager.io/docs/installation/kubernetes

# Create namespace for cert manager...

# https://terraform.io/docs/providers/kubernetes/index.html

resource "kubernetes_namespace" "cert-manager" {

  metadata {
    name = "cert-manager"
  }

  lifecycle {
    prevent_destroy = true
  }

}

# Get the JetStack Helm repository...

data "helm_repository" "jetstack" {

  depends_on = [kubernetes_namespace.cert-manager]

  name = "jetstack"
  url  = "https://charts.jetstack.io"

}

# Install the JetPack Helm repository...

resource "helm_release" "cert-manager" {

  depends_on = [
    kubernetes_namespace.cert-manager,
    data.helm_repository.jetstack
  ]

  name       = "cert-manager"
  repository = data.helm_repository.jetstack.metadata[0].name
  chart      = "jetstack/cert-manager"

  lifecycle {
    prevent_destroy = true
  }

}

# kubectl get-pods --namespace cert-manager

# -------
# Rancher
# -------

resource "kubernetes_namespace" "rancher" {

  metadata {
    name = "rancher"
  }

  lifecycle {
    prevent_destroy = true
  }

}

# Get the Rancher Helm repository...

data "helm_repository" "rancher" {

  depends_on = [kubernetes_namespace.rancher]

  name = "rancher-stable"
  url  = "https://releases.rancher.com/server-charts/stable"

}

# Install the Rancher Helm repository...

resource "helm_release" "rancher" {

  depends_on = [
    kubernetes_namespace.rancher,
    data.helm_repository.rancher
  ]

  name       = "rancher-stable"
  repository = data.helm_repository.rancher.metadata[0].name
  chart      = "rancher-stable/rancher"

  set {
    name  = "addLocal"
    value = "true"
  }

  set {
    name  = "hostname"
    value = "rancher.morsley.io"
  }

  lifecycle {
    prevent_destroy = true
  }

}

//resource "null_resource" "is-rancher-ready" {
//
//  depends_on = [helm_release.rancher]
//
//  connection {
//    type        = "ssh"
//    host        = aws_instance.k8s.public_ip
//    user        = "ubuntu"
//    private_key = join("", tls_private_key.node_key.*.private_key_pem)
//  }
//
//  provisioner "local-exec" {
//    command = "chmod +x scripts/is_rancher_ready.sh && bash scripts/is_rancher_ready.sh"
//  }
//
//  lifecycle {
//    prevent_destroy = true
//  }
//  
//}