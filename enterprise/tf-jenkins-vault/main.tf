terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "emea-se-playground-2019"
    workspaces {
      name = "emea-terraform-jenkins"
    }
  }
}

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

resource "aws_instance" "jenkins" {
  ami           = "${lookup(var.ami, var.region)}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_name}"
  user_data     = "${file("./init_install.sh")}"

  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    volume_size = "${var.volume_size}"
  }

  vpc_security_group_ids = [
    "${aws_security_group.jenkins_sg.id}",
  ]

  tags {
    Name  = "jenkins"
    owner = "${var.tag_owner}"
    TTL   = "${var.tag_ttl}"
  }

  provisioner "file"{

    content = "jenkins/"
    destination = "/var/jenkins"
  }

}

resource "aws_eip" "jenkins" {
  instance = "${aws_instance.jenkins.id}"
}

# resource "aws_key_pair" "ptfe_key_pair" {
#   key_name   = "${var.key_name}"
#   public_key = "${var.public_key}"
# }

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_inbound"
  description = "Allow jenkins ports and ssh from Anywhere"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


output "ec2 machine dns" {
  value = "${aws_instance.jenkins.public_dns}"
}
