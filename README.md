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


🔟 Configure Kernel Parameters
sudo nano /etc/sysctl.conf

Add c:

vm.max_map_count=524288
fs.file-max=131072
sudo sysctl -p


1️⃣1️⃣ Configure System Limits
sudo nano /etc/security/limits.conf

Add below:

sonar   -   nofile   131072
sonar   -   nproc    8192


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


