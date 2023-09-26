variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}
variable "Path_to_ssh" {
  type    = string
  default = "./keys/my_aws_key.pub"
}
###################################
variable "templateVarHello" {
  type    = string
  default = "Hello"
}

variable "templateVar1" {
  type    = list(string)
  default = ["John", "Smith", "Samanta", "Anna"]
}

###################################
data "aws_region" "current" {}
data "aws_availability_zones" "current" {}
data "aws_caller_identity" "current_account" {}
data "aws_ami" "latest_free_ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-202*-kernel-6.1-x86_64"]
  }
}
/*
data "aws_ami" "latest_free_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}
*/
