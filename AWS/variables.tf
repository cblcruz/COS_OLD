# AWS Environment and credentions
variable "access_key" {
  type    = string
  default = "AWS Access Key"
}

variable "secret_key" {
  type    = string
  default = "AWS Secret Key"
}

variable "region" {
  type    = string
  default = "region"
}

variable "vpc_id" {
  type    = string
  default = "AWS vpc id"
}

variable "subnet_id" {
  type    = string
  default = "AWS Subnet id"
}

variable "ec2_OS" {
  type    = string
  default = "ubuntu"
}

variable "ec2_instance_user" {
  type    = string
  default = "povadmin"
}

variable "lb_create" {
  type        = bool
  default     = false
  description = "Boolean to determine whether or not we want to create an ELB."
}

# Cribl Environment variables

variable "username" {
  type    = string
  default = "povadmin"
}

variable "cribl_pass" {
  type    = string
  default = "passtest"
}

variable "leader_count" {
  type    = number
  default = 1
}
variable "worker_size" {
  type    = string
  default = "t3.micro"
}

variable "workers_count" {
  type    = number
  default = 1
}

variable "worker_group" {
  type    = string
  default = "POV"
}

# Satellite Box variables

variable "satellite_box" {
  type        = bool
  default     = false
  description = "Deploy an instance to host all docker containers?"
}

variable "satellite_count" {
  type    = number
  default = 1
}

variable "satellite_box_size" {
  type    = string
  default = "t3.2xlarge"
}

variable "satellite_disk_size" {
  type    = number
  default = 65
}

# Satallite Box Docker containers variables

variable "splunk" {
  type        = bool
  default     = false
  description = "running a splunk instance for testing?"
}

variable "splunk_receiving_port" {
  type        = number
  default     = 9997
  description = "splunk receiving port"
}


variable "elk" {
  type        = bool
  default     = false
  description = "running ELK stack?"
}

variable "redis" {
  type        = bool
  default     = false
  description = "running Redis?"
}

variable "minio" {
  type        = bool
  default     = false
  description = "running Minio?"
}

# variable "docker_ports" {
#   type = list(object({
#     internal = number
#     external = number
#     protocol = string
#   }))
# }

# variable "worker_ports" {
#   type = list(object({
#     internal = number
#     external = number
#     protocol = string
#   }))
# }

variable "splunk_user" {
  type    = string
  default = "admin"
}

variable "splunk_passwd" {
  type    = string
  default = "passtest"
}

variable "elastic_user" {
  type    = string
  default = "elastic"
}

variable "elastic_passwd" {
  type    = string
  default = "passtest"
}

# Generic Varirables 

variable "syslog_port_tcp" {
  type    = number
  default = 9514
}

variable "syslog_port_udp" {
  type    = number
  default = 9514
}