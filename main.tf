terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
    region     = "eu-central-1"
  access_key = "your access_key "
  secret_key = "your secret_key"
}

resource "aws_instance" "web_server" {
    ami = "ami-0c9354388bb36c088"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install curl
                sudo curl -fsSL https://get.docker.com/ | sh
                sudo systemctl restart docker
                mkdir ~/wordpress && cd ~/wordpress
                sudo docker run -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=wordpress --name wordpressdb -v "$PWD/database":/var/lib/mysql -d mariadb:latest
                sudo docker pull wordpress
                sudo docker run -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=password --name wordpress --link wordpressdb:mysql -p 80:80 -v "$PWD/html":/var/www/html -d wordpress
                EOF

    tags = {
        Name = "web_server1"
    }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

