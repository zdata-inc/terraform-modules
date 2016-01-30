resource "template_file" "chef-bootstrap" {
    template = "${file("${path.module}/templates/chef-bootstrap.erb.sh")}"

    vars {
        chef_server_fqdn = "${var.chef_server_fqdn}"
        admin_user_name = "${var.admin_user_name}"
        admin_password = "${var.admin_password}"
        admin_first_name = "${var.admin_first_name}"
        admin_last_name = "${var.admin_last_name}"
        admin_email = "${var.admin_email}"
        org_full_name = "${var.org_full_name}"
        org_short_name = "${var.org_short_name}"
    }
}

resource "template_file" "knife-rb" {
    template = "${file("${path.module}/templates/knife.erb")}"

    vars {
        chef_server_url = "https://${aws_instance.chef-server.public_ip}/organizations/${var.org_short_name}"
        admin_user_name = "${var.admin_user_name}"
        org_short_name = "${var.org_short_name}"
    }
}

resource "aws_instance" "chef-server" {
    ami = "${var.ami_id}"
    instance_type = "${var.aws_instance_type}"
    subnet_id = "${var.aws_subnet_id}"
    associate_public_ip_address = "true"
    security_groups = ["${var.aws_security_group}"]
    key_name = "${var.aws_key_name}"

    connection {
        user = "${var.ssh_user}"
        private_key = "${file("${var.private_key_path}")}"
    }

    provisioner "file" {
        source = "${path.module}/templates/chef-server.rb"
        destination = "/tmp/chef-server.rb"
    }

    provisioner "remote-exec" {
        inline = [
            "cat <<EOF > /tmp/chef-bootstrap.sh",
            "${template_file.chef-bootstrap.rendered}",
            "EOF",
            "chmod 755 /tmp/chef-bootstrap.sh",
            "/tmp/chef-bootstrap.sh",
        ]
    }

    provisioner "local-exec" {
        command = "mkdir -p ./.chef; mkdir -p ./artifacts/keys; cat <<EOF > .chef/knife.rb ${template_file.knife-rb.rendered} EOF"
    }

    provisioner "local-exec" {
        command = "scp -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.ssh_user}@${aws_instance.chef-server.public_ip}:${var.admin_user_name}.pem ./artifacts/keys/."
    }

    provisioner "local-exec" {
        command = "scp -i ${var.private_key_path} -o StrictHostKeyChecking=no ${var.ssh_user}@${aws_instance.chef-server.public_ip}:${var.org_short_name}-validator.pem ./artifacts/keys/."
    }

    provisioner "local-exec" {
        command = "if [ -d ./cookbooks -a -n `(ls -la ./cookbooks)` ]; then knife cookbook upload $(ls cookbooks)"
    }

    tags {
        Name = "chef-server"
    }
}
