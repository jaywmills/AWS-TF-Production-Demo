# Compute Variables
variable "linux_ami" {
  default = "ami-0b0dcb5067f052a63"
}

variable "windows_ami" {
  default = "ami-026bb75827bd3d68d"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  type      = string
  default   = ("~/.ssh/tf_keypair.pub")
  sensitive = true
}

variable "vpc_id" {
  default = "10.0.0.0/16"
}

# Database Variables
variable "multi_az" {
  default = false
}

variable "db_name" {
  default = "PostgreSQL_DB"
}

variable "engine_version" {
  default = "13.7"
}

variable "allocated_storage" {
  default = "10"
}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "engine" {
  default = "postgres"
}

variable "private_sn_count" {
  type    = number
  default = 2
}

variable "public_sn_count" {
  type    = number
  default = 2
}