1️⃣ Launch EC2 Instance
Amazon Linux 2023
Instance: t3.large
Storage: 50–60 GB SSD
Open Port: 9000


2️⃣ Connect to EC2
cd Downloads
chmod 400 sonar.pem
ssh -i "sonar.pem" ec2-user@<your-public-ip>


3️⃣ Update Server
sudo dnf update -y
sudo dnf install wget unzip git -y


4️⃣ Install Java 17
sudo dnf install java-17-amazon-corretto -y
java -version
readlink -f $(which java)


5️⃣ Install PostgreSQL
sudo dnf install postgresql15 postgresql15-server -y
sudo /usr/bin/postgresql-setup --initdb

sudo systemctl enable postgresql
sudo systemctl start postgresql
sudo systemctl status postgresql


6️⃣ Create SonarQube Database
sudo -i -u postgres
psql
CREATE DATABASE sonarqube;
CREATE USER sonar WITH PASSWORD 'StrongPassword';
ALTER USER sonar WITH ENCRYPTED PASSWORD 'StrongPassword';
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;

\q

exit


7️⃣ Install SonarQube
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.4.87374.zip
sudo unzip sonarqube-9.9.4.87374.zip
sudo mv sonarqube-9.9.4.87374 sonarqube


8️⃣ Create SonarQube User
sudo useradd sonar
sudo chown -R sonar:sonar /opt/sonarqube


9️⃣ Configure Database Connection
sudo nano /opt/sonarqube/conf/sonar.properties

Add below:
sonar.jdbc.username=sonar
sonar.jdbc.password=StrongPassword
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube

save&exit.

🔟 Configure Kernel Parameters
sudo nano /etc/sysctl.conf

Add below:
vm.max_map_count=524288
fs.file-max=131072

save&exit.

sudo sysctl -p


1️⃣1️⃣ Configure System Limits
sudo nano /etc/security/limits.conf

Add below (before: '# End of file'):
sonar   -   nofile   131072
sonar   -   nproc    8192

save&exit.


1️⃣2️⃣ Create SonarQube Service
sudo nano /etc/systemd/system/sonarqube.service

Paste:
[Unit]
Description=SonarQube Service
After=network.target

[Service]
Type=forking
User=sonar
Group=sonar

LimitNOFILE=65536
LimitNPROC=4096

Environment="JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto.x86_64"
Environment="PATH=/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin:/usr/local/bin:/usr/bin:/bin"

ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop

Restart=always

[Install]
WantedBy=multi-user.target

save+exit.

sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube
sudo systemctl status sonarqube


1️⃣3️⃣ Fix PostgreSQL Authentication
sudo nano /var/lib/pgsql/data/pg_hba.conf

Update below (remove  both old tables and add the below):
# TYPE  DATABASE        USER            ADDRESS                 METHOD
local   all             postgres                                peer
local   all             all                                     peer
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5

save+exit.

sudo systemctl restart postgresql


#1️⃣4️⃣ Verify Database Access
#psql -U sonar -d sonarqube -h localhost
#(write password: StrongPassword)
#\q


1️⃣5️⃣ Set Database Ownership
sudo -i -u postgres
psql

paste below:
ALTER DATABASE sonarqube OWNER TO sonar;
GRANT ALL PRIVILEGES ON DATABASE sonarqube TO sonar;

\q


1️⃣6️⃣ Access SonarQube
http://<your-public-ip>:9000

1️⃣7️⃣ Default Login
Field	Value
Username	admin
Password	admin

👉 You will be prompted to change password on first login.


1️⃣8️⃣ Sonar Scanner Installation

cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
sudo unzip sonar-scanner-cli-5.0.1.3006-linux.zip
sudo mv sonar-scanner-5.0.1.3006-linux sonar-scanner

echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee /etc/profile.d/sonar-scanner.sh
source /etc/profile.d/sonar-scanner.sh


sonar-scanner -h
sonar-scanner -v



1️⃣8️⃣ sonar scanner installation & configuration | manual

sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
sudo unzip sonar-scanner-cli-5.0.1.3006-linux.zip
sudo mv sonar-scanner-5.0.1.3006-linux sonar-scanner

sudo nano /opt/sonar-scanner/conf/sonar-scanner.properties

update below:
sonar.host.url=http://localhost:9000
sonar.sourceEncoding=UTF-8

if EC2-instance/remote

update below:
sonar.host.url=http://<your-server-ip>:9000


1️⃣9️⃣ Set Environment Variables

sudo nano /etc/profile.d/sonar-scanner.sh

add below:
#!/bin/bash
export PATH=$PATH:/opt/sonar-scanner/bin

save+exit.

2️⃣0️⃣ give permission

sudo chmod +x /etc/profile.d/sonar-scanner.sh


2️⃣1️⃣ load env

source /etc/profile.d/sonar-scanner.sh


2️⃣2️⃣verify installation

sonar-scanner -h
