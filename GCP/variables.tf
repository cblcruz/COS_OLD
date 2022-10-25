variable "project" {
  type    = string
  default = "Project ID"
}

variable "region" {
  type    = string
  default = "Region"
}

variable "zone" {
  type    = string
  default = "Zone"
}

variable "workers_count" {
  type    = number
  default = 1
}

variable "satellite_box" {
  type    = bool
  default = false
}