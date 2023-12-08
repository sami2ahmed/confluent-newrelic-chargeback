resource "aws_security_group" "allow_ssh" {
  description = "SSH Inbound"
  name        = "${var.owner}-allow-ssh"
  vpc_id      = aws_vpc.new_rel.id

  ingress {
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 22
    to_port          = 22
    ipv6_cidr_blocks = null
    prefix_list_ids  = null
    security_groups  = null
    self             = null
  }

  ingress {
    from_port   = 1521 
    to_port     = 1521
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    security_groups  = null
  }

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_groups  = null
  }

}

resource "aws_instance" "sami_ec2_new_rel" {
  ami  = var.ami
  instance_type = "t3.medium"
  key_name = "${var.key}"
  associate_public_ip_address = true
  vpc_security_group_ids = [ aws_security_group.allow_ssh.id ]
  subnet_id = aws_subnet.new_rel["az2"].id
 // vpc_security_group_ids = [ aws_security_group.rds.id ]
  root_block_device {
    volume_size = 20
  }
}

output "build" {
  value = {
    ip  = aws_instance.sami_ec2_new_rel.public_ip,
    dns = aws_instance.sami_ec2_new_rel.public_dns,
  }
}