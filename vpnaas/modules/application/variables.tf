variable "region" {
  type = string
}

variable "name" {
  type    = string
  default = "unicorn"
}

variable "image_name" {
  type        = string
  description = "Openstack image node"
  default     = null
}

variable "network" {
  type    = string
  default = "unicorn"
}

variable "public_key" {
  type = string
}

variable "flavor" {
  type = string
  default = "m2.tiny"
}

variable "port_id" {
  type = string
}

variable "app_depends_on" {
  type    = any
    default = null
}
