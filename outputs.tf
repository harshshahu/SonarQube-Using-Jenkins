output "instance_public_ip" {
  description = "Public IP address of the Jenkins instance"
  value = aws_instance.Jenkins_VM.public_ip
}

output "ssh_connection_command" {
  description = ""
  value = "ssh -i jenkins_private_key.pem ec2-user@${aws_instance.Jenkins_VM.public_ip}"
}

output "jenkins_vm_admin_password_command" {
  description = ""
  value = "ssh -i jenkins_private_key.pem ec2-user@${aws_instance.Jenkins_VM.public_ip} 'sudo cat /var/lib/jenkins/secrets/initialAdminPassword'"
}

output "jenkins_vm_url" {
  description = "URL to access Jenkins"
  value = "http://${aws_instance.Jenkins_VM.public_ip}:8080"
}