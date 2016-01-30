#variable "aws_access_key" {}
#variable "aws_secret_key" {}
#variable "aws_region" {
#    description = "The default AWS region to use"
#    default = "us-east-1"
#}
variable "ami_id" {}
variable "aws_instance_type" {
    default = "t2.small"
}
variable "aws_subnet_id" {}
variable "aws_security_group" {}
variable "aws_key_name" {}
variable "ssh_user" {
    default = "centos"
}
variable "private_key_path" {}
variable "chef_server_fqdn" {}
variable "admin_user_name" {}
variable "admin_password" {}
variable "admin_first_name" {}
variable "admin_last_name" {}
variable "admin_email" {}
variable "org_full_name" {}
variable "org_short_name" {}
