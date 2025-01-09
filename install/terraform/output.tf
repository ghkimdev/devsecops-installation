output "jenkins_ip" {
  value = aws_instance.jenkins.public_ip
}
output "nexus_ip" {
  value = aws_instance.nexus.public_ip
}
output "sonarqube_ip" {
  value = aws_instance.sonarqube.public_ip
}

output "jenkins_dns" {
  value = aws_instance.jenkins.public_dns
}
output "nexus_dns" {
  value = aws_instance.nexus.public_dns
}
output "sonarqube_dns" {
  value = aws_instance.sonarqube.public_dns
}

output "eks_cluster_name" {
  value = aws_eks_cluster.example.name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.petclinic.repository_url
}
