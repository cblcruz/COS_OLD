
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

