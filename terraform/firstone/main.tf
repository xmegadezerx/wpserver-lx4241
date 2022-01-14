terraform {
  required_version = "=1.0"
}

provider "aws" {
  region  = "us-east-1"
}

#creating security group with ssh and http

resource "aws_security_group" "mainsecgroup" {
         name = "mainsecgroup"

         ingress {
                 from_port = 22
                 to_port = 22
                 protocol = "tcp"
                 cidr_blocks = ["0.0.0.0/0"]
         }
         
         ingress {
                 from_port = 80
                 to_port = 80
                 protocol = "tcp"
                 cidr_blocks = ["0.0.0.0/0"]

         }

         egress {
                 from_port = 0
                 to_port = 0
                 protocol = "-1"
                 cidr_blocks = ["0.0.0.0/0"]
         }

}

#creating key-pair for logging into EC2 in us-east-1
resource "aws_key_pair" "worker-key" {
  key_name   = "wpserver"
  public_key = file("${path.module}/wpserver.pub")
}

#creating aws_instance
resource "aws_instance" "app_server" {
  ami           = "ami-0e472ba40eb589f49"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.mainsecgroup.name}"]
  key_name = "wpserver"
  tags = {
    Name = "wpserver"
  }

  user_data = <<EOD
#!/bin/bash
sudo apt-get update -y
sudo apt install software-properties-common -y
sudo apt-add-repository ppa:ansible/ansible -y
sudo apt update -y",
sudo apt install git -y",
git clone https://github.com/xmegadezerx/wpserver2.git /tmp/wp
sudo apt install ansible -y
ansible-playbook /tmp/wp/ansible/wordpress/playbook.yml
EOD
}

module "bastion" {
  source = "./modules/bastion"

  sg_list = ["${aws_security_group.mainsecgroup.name}"]
  ssh_key = "wpserver"
}

data "template_file" "ansible" {
  template = file("${path.module}/inventory.tmpl")
  vars = {
    bastion_ip = module.bastion.public_ip
    webserver_ip = aws_instance.app_server.public_ip
  }
}

resource "null_resource" "bastion" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible.rendered}' > ./hosts.ini"
  }
}
