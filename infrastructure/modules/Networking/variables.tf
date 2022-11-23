variable "vpc_cidr" {}

variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "vpc_id" {
  default = "10.0.0.0/16"
}

variable "public_cidrs" {
  type    = list(any)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_cidrs" {
  type    = list(any)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "private_sn_count" {
  type    = number
  default = 2
}

variable "public_sn_count" {
  type    = number
  default = 2
}

variable "internal_ec2" {}