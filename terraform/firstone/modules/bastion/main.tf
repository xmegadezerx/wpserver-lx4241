resource "aws_instance" "bastion_host" {
  ami           = "ami-0e472ba40eb589f49"
  instance_type = "t2.micro"
  security_groups = var.sg_list
  key_name = var.ssh_key
  tags = {
    Name = "bastion"
  }
}
