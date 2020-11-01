#############################################
## Set the IP address to connect to the Bastion host.
variable "my-ip-address" {
  description = "Enter the IP address that connects to the Bastion EC2"
  default = ["0.0.0.0/0"]
}

##################################
## Set the name of the name space.
variable "cicd-ns" {
  default = "cicd"
}
variable "nginx-ns" {
  default = "nginx"
}
variable "monitoring-ns" {
  default = "monitoring"
}

####################
## Necessary Objects... (CICD, Nginx-ingress)
variable "jenkins-path" {
  description = "Input the path to Jenkins' values.yaml here"
}
variable "argo-path" {
  description = "Input the path to Argo' values.yaml here"
}
variable "nginx-path" {
  description = "Input the path to nginx-ingress-controller' values.yaml here"
}

####################
## Monitoring Pods
variable "metric-path" {
  description = "Input the path to metric-server' values.yaml here"
}
variable "prometheus-path" {
  description = "Input the path to prometheus' values.yaml here"
}
variable "grafana-path" {
  description = "Input the path to grafana' values.yaml here"
}
variable "datadog-path" {
  description = "Input the path to datadog' values.yaml here"
}
variable "datadog-apikey" {
  description = "Input Your Datadog's APIKeys"
  default = ""
}

####################
## Select one of the monitoring tools.
variable "prometheus_or_datadog" {
  description = "If true, deploy Prometheus, if false, deploy datadog. default is prometheus"
  default = "true"
}