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

  load_config_file = true
  #config_path            = "rancher/${var.kube_config_filename}"
  #config_context_cluster = var.cluster_name

}

# Helm: https://terraform.io/docs/providers/helm/index.html

# -----------------------
# Cert-Manager - JetStack
# -----------------------

# GitHub --> https://github.com/jetstack/cert-manager

# Jetstack - Kubernetes --> https://cert-manager.io/docs/installation/kubernetes

# Create namespace for cert manager...

# https://terraform.io/docs/providers/kubernetes/index.html

resource "kubernetes_namespace" "cert-manager" {

  metadata {
    name = "cert-manager"
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

  #version    = "v0.14.0" # Latest stable, but latest is at: 0.14.0-alpha.1
  version    = "v0.14.0-alpha.1"
  name       = "cert-manager"
  repository = data.helm_repository.jetstack.metadata[0].name
  chart      = "jetstack/cert-manager"
  namespace  = "cert-manager"
  wait       = true
  timeout    = 900 # In seconds, 15 minutes
  #verify = true

}

# kubectl get-pods --namespace cert-manager

# -------
# Rancher
# -------



resource "kubernetes_namespace" "rancher" {

  metadata {
    name = "cattle-system"
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
    kubernetes_namespace.cert-manager,
    helm_release.cert-manager,
    kubernetes_namespace.rancher,
    data.helm_repository.rancher
  ]

  #version    = "v2.3.5" # Latest stable, but RC is at 2.4.0-rc2
  #version    = "v2.4.0"
  name       = "rancher"
  repository = data.helm_repository.rancher.metadata[0].name
  chart      = "rancher-stable/rancher"
  namespace  = "cattle-system"
  wait       = true
  timeout    = 900 # In seconds, 15 minutes
//  #verify = true

////  set {
////    name  = "addLocal"
////    value = "true"
////  }

  set {
    name  = "hostname"
    value = "rancher.morsley.io"
  }

  set {
    name  = "ingress.tls.source"
    value = "rancher"
  }

////  set {
////    name  = "ingress.tls.source"
////    value = "letsEncrypt"
////  }
//
////  set {
////    name  = "letsEncrypt.email"
////    value = "lets.encrypt@morsley.io"
////  }
////
////  set {
////    name  = "webhook.enabled"
////    value = "false"
////  }
////
////  set {
////    name  = "ingressShim.defaultIssuerName"
////    value = "letsencrypt-staging" # -prod when live
////  }
////
////  set {
////    name  = "ingressShim.defaultIssuerKind"
////    value = "ClusterIssuer"
////  }
////
////  set {
////    name  = "ingressShim.defaultIssuerGroup"
////    value = "cert-manager.io"
////  }
////  
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