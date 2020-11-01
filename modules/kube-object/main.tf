provider "kubernetes" {
  config_path = "~/.kube/config"
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Create Namespaces
resource "kubernetes_namespace" "nginx" {
  metadata {
    name = var.nginx-ns
  }
}
resource "kubernetes_namespace" "cicd" {
  metadata {
    name = var.cicd-ns
  }
}
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring-ns
  }
}

# Deploy Nginx-Ingress-Controller
data "helm_repository" "nginx" {
  name = "ingress-nginx"
  url  = "https://kubernetes.github.io/ingress-nginx"
}
resource "helm_release" "nginx" {
  name       = "nginx-ingress"
  repository = data.helm_repository.nginx.metadata[0].name
  chart      = "ingress-nginx/ingress-nginx"
  values = [
    file(var.nginx-path)
  ]

  namespace = var.nginx-ns
}

# Deploy Metric-Server
data "helm_repository" "metric-server" {
  name = "stable"
  url  = "https://charts.helm.sh/stable"
}
resource "helm_release" "metric-server" {
  name       = "metric-server"
  repository = data.helm_repository.metric-server.metadata[0].name
  chart      = "stable/metrics-server"
  values = [
    file(var.metric-path)
  ]

  namespace = var.monitoring-ns
}

# If variable set true, Deploy Prometheus & Grafana
data "helm_repository" "prometheus" {
  count = var.prometheus_or_datadog? 1 : 0

  name = "prometheus-community"
  url  = "https://prometheus-community.github.io/helm-charts"
}
resource "helm_release" "prometheus" {
  count = var.prometheus_or_datadog? 1 : 0

  name       = "prometheus"
  repository = data.helm_repository.prometheus.metadata[0].name
  chart      = "prometheus-community/prometheus"
  values = [
    file(var.prometheus-path)
  ]

  namespace = var.monitoring-ns
}
data "helm_repository" "grafana" {
  count = var.prometheus_or_datadog? 1 : 0

  name = "grafana"
  url  = "https://grafana.github.io/helm-charts"
}
resource "helm_release" "grafana" {
  count = var.prometheus_or_datadog? 1 : 0

  name       = "grafana"
  repository = data.helm_repository.grafana.metadata[0].name
  chart      = "grafana/grafana"
  values = [
    file(var.grafana-path)
  ]

  namespace = var.monitoring-ns
}

# If variable set false, Deploy Datadog
data "helm_repository" "datadog" {
  count = var.prometheus_or_datadog? 0 : 1

  name = "datadog"
  url  = "https://helm.datadoghq.com"
}
resource "helm_release" "datadog" {
  count = var.prometheus_or_datadog? 0 : 1

  name       = "datadog"
  repository = data.helm_repository.datadog.metadata[0].name
  chart      = "datadog/datadog"
  values = [
    file(var.datadog-path)
  ]

  set {
    name = "datadog.apiKey"
    value = var.datadog-apikey
  }
  set {
    name = "datadog.site"
    value = "datadoghq.com"
  }

  namespace = var.monitoring-ns
}

# Deploy Jenkins
data "helm_repository" "jenkins" {
  name = "jenkins"
  url  = "https://charts.jenkins.io"
}
resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = data.helm_repository.jenkins.metadata[0].name
  chart      = "jenkins/jenkins"
  values = [
    file(var.jenkins-path)
  ]
  namespace = var.cicd-ns
}
# Deploy ArgoCD
data "helm_repository" "argo" {
  name = "argo"
  url  = "https://argoproj.github.io/argo-helm"
}
resource "helm_release" "argo" {
  name       = "argo"
  repository = data.helm_repository.argo.metadata[0].name
  chart      = "argo/argo-cd"
  values = [
    file(var.argo-path)
  ]
  namespace = var.cicd-ns
}

