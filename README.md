1️⃣ Launch EC2 Instance
Amazon Linux 2023
Instance: t3.large
Storage: 50–60 GB SSD
Open Port: 9000


2️⃣ Connect to EC2
cd Downloads
chmod 400 sonar.pem
ssh -i "sonar.pem" ec2-user@<your-public-ip>

