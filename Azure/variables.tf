
variable "subscription_id" {
  type    = string
  default = "Your Azure subscription ID"
}

variable "tenant_id" {
  type    = string
  default = "Your Azure tenant ID"
}

variable "az_location" {
  type    = string
  default = "Your Azure locaation for deployment"
}

variable "workers_count" {
  type    = number
  default = 1
}


variable "worker_size" {
  type    = string
  default = "Standard_ds1_v2"
}

variable "lb_create" {
  type        = bool
  default     = false
  description = "Boolean to determine whether or not we want to create a availabilty set."
}
variable "leader_count" {
  type    = number
  default = 1

}

variable "cribl_pass" {
  type    = string
  default = "passtest"
}

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
  default = "admin"
}

variable "elastic_passwd" {
  type    = string
  default = "passtest"
}
variable "satellite_privete_ip" {
  type    = string
  default = "1.1.1.1"
}

