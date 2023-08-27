variable "ec2_instance_type" {
    type = string
    default = "t2.micro" 
}
variable "Path_to_ssh" {
  type = string
  default = "./keys/my_aws_key.pub"
}
variable "access_key" {
    type = string
    default = "AKIAYDDRM52WFMRRDYPG"
    sensitive = true
}

variable "secret_key" {
    type = string
    default = "GRqDUOBl6uz9wYXq6rVa7a/dPj/zCaYfSklfGRtE"
    sensitive = true
}
###################################
variable "templateVarHello" {
    type = string
    default = "Hello"
}

variable "templateVar1" {
    type = list(string)
    default = ["John","Smith","Samanta","Anna"]
}

###################################
data "aws_region" "current" {}
data "aws_availability_zones" "current" {}
data "aws_caller_identity" "current_account" {}
data "aws_ami" "latest_free_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] 
  }
}