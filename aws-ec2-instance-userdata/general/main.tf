provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "jray_jenkins" {
  vpc_id        = "sg-08dc78d1f405f6f4d"
  ami           = "ami-0600ae90df54755e1"
  instance_type = "t2.micro"

  tags {
    Name  = "jray_jenkins"
    owner = "jray@hashicorp.com"
    TTL   = "-1"
  }

  user_data = "./user-data/user_data.sh"
  key_name  = "jray"
  subnet_id = ["subnet-055c621fd6b3df116,subnet-05f16307416fe2c02"]

  vpc_security_group_ids = "vpc-0a8898bdcbdde208f"
}
