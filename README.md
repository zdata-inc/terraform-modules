# terraform-modules

## Module Configuration Example for Chef-Server on AWS
There are a couple files to update to get one of the modules to work. 

### Variables Terraform Files
Add the following variable definitions to either your top-level Terraform variables file or inside your main Terraform file.
```
variable "aws_instance_type" {
    default = "t2.micro"
}
variable "chef_instance_type" {
    default = "t2.small"
}
variable "chef_server_fqdn" {
    default = "chef-server.zdatacloud.local"
}

variable "chef_admin_user_name" {}
variable "chef_admin_password" {}
variable "chef_admin_first_name" {}
variable "chef_admin_last_name" {}
variable "chef_admin_email" {}
variable "chef_org_full_name" {}
variable "chef_org_short_name" {}
```

### Top-Level Terraform File
Add this to your main Terraform file. Note - if you do not want to use variables, you can directly replace the variables with the values you need. However, it is recommended to keep your configuration and the actual Terraform config separate so that sensitive information isn't stored in a repository accidently.

* source - The sub-directory of the module you want to use. (Since this repo eventually will contain more than one module)
* ami_id - The AMI to use which is dependent on the region. The example below uses another variable for lookup.
* aws_key_name - Can be another resource or an actual key name already created.
* aws_security_group - Can be another resource or an existing security group id. The security group must be in the same VPC and region as the rest of your resources.
* private_key_path - The relative path from the top-level Terraform files of where a pre-existing key is. This is used for provisioning the Chef server.
* aws_instance_type - The size of the instance to use for your Chef server.
* chef_server_fqdn - The fully qualified domain name to use for the Chef server. The provisioner will set the hostname of the instance to this.
* admin_user_name - The name of the admin username to create.
* admin_password - The password to use.
* admin_first_name - First name of user.
* admin_last_name - Last name of user.
* admin_email - The administrator's email.
* org_full_name - The full organization name to create. Spaces are not tested.
* org_short_name - The short name of the organization. Must not contain any spaces.
```
module "chef-server" {
    source = "git::https://github.com/zdata-inc/terraform-modules.git//chef-server//AWS"
    ami_id = "${lookup(var.centos_6_amis, var.aws_region)}"
    aws_key_name = "${aws_key_pair.benchmarking_key.key_name}"
    aws_security_group = "${aws_security_group.greenplum_sg.id}"
    aws_subnet_id = "${aws_subnet.public_benchmarking.id}"
    private_key_path = "./artifacts/keys/id_rsa"
    aws_instance_type = "${var.chef_instance_type}"
    chef_server_fqdn = "${var.chef_server_fqdn}"
    admin_user_name = "${var.chef_admin_user_name}"
    admin_password = "${var.chef_admin_password}"
    admin_first_name = "${var.chef_admin_first_name}"
    admin_last_name = "${var.chef_admin_last_name}"
    admin_email = "${var.chef_admin_email}"
    org_full_name = "${var.chef_org_full_name}"
    org_short_name = "${var.chef_org_short_name}"
}
```

### Edit terraform.tfvars File
Add these entries to your terraform.tfvars file. Change to whatever you want! Spaces in names may break the installer.It has not been  tested.
```
chef_instance_type = "t2.small"
chef_server_fqdn = "chef-server.zdatacloud.local"
chef_admin_user_name = "admin"
chef_admin_password = "areallybadpwd?"
chef_admin_first_name = "Harry"
chef_admin_last_name = "Waffles"
chef_admin_email = "harry@example.com"
chef_org_full_name = "zData_Inc"
chef_org_short_name = "zdata"
```
