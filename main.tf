terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.41.0"
    }
  }
}

provider "aws" {
    region = "ap-south-1"
}

resource "tls_private_key" "jenkins_private_key" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "local_file" "jenkins_private_key" {
    content = tls_private_key.jenkins_private_key.private_key_pem
    filename = "jenkins_private_key.pem"
    file_permission = "0400"
    directory_permission = "0700"
}

resource "aws_key_pair" "jenkins_private_key" {
    key_name = "jenkins_private_key"
    public_key = tls_private_key.jenkins_private_key.public_key_openssh
}

resource "aws_security_group" "jenkins_security_group" {
    name = "jenkins_security_group"
    description = "Allow SSH, HTTP, HTTPS, and Jenkins, Maven port, SonarQube port"

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

    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 5000
        to_port = 5000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 9000
        to_port = 9000
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

resource "aws_instance" "Jenkins_VM" {
    ami = "ami-0e12ffc2dd465f6e4"
    instance_type = "t2.large"
    key_name = aws_key_pair.jenkins_private_key.key_name
    vpc_security_group_ids = [ aws_security_group.jenkins_security_group.id ]

    tags = {
        Name = "Jenkins_VM"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo yum update -y",
            "sudo yum install -y git docker maven tree",
            "sudo systemctl start docker",
            "sudo systemctl enable docker",

            "sudo git config --global user.name 'Harsh Shahu'",
            "sudo git config --global user.email 'shahuharsh22@gmail.com'",

            "sudo yum install java-21-amazon-corretto.x86_64 -y",

            "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo",
            "sudo rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2023.key",
            "sudo yum upgrade -y",
            "sudo yum install fontconfig java-21-openjdk -y",
            "sudo yum install jenkins -y",
            "sudo systemctl daemon-reload",

            "sudo java -version",

            "sudo usermod -aG docker jenkins",

            "sudo systemctl enable jenkins",
            "sudo systemctl start jenkins",

            "sudo yum install npm -y",
            "sudo npm -v",

            "echo 'Jenkins Admin Password:'",
            "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
        ]
    }

    connection {
        type        = "ssh"
        user        = "ec2-user"
        private_key = tls_private_key.jenkins_private_key.private_key_pem
        host        = self.public_ip
    }
}

