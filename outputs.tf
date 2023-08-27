output "vpc_id" {
    value = aws_vpc.myvpc.id
}

output "public_sub" {
  value = aws_subnet.publicsubnet.id
}

output "private_sub" {
  value = aws_subnet.privatesubnet.id
}

output "instance_http_public_ip" {
    value = "http://${aws_instance.Test.public_ip}"
}
output "data_current_account_id" {
    value = data.aws_caller_identity.current_account.account_id 
}
output "data_current_region_id" {
    value = data.aws_region.current.id
}
output "data_current_region_name" {
    value = data.aws_region.current.description
}
output "data_availability_zones" {
    value = data.aws_availability_zones.current.names
}
output "selected_free_ami_id" {
  value = data.aws_ami.latest_free_ami.id
}