
# DevSecOps Infrastructure 설정

이 저장소는 Terraform과 Ansible을 사용하여 DevSecOps 인프라를 구축하는 가이드를 제공합니다. Terraform으로 AWS의 VPC, EC2, ECR, S3, EKS를 생성하고, Ansible로 각 EC2에 Jenkins와 Nexus, SonarQube를 설치해 SSL을 적용합니다. 그리고 EKS에는 helm을 이용해 ArgoCD, Ingress-Nginx, Cert-Manager를 설치합니다.


## 사전 요구사항
1. AWS 계정
2. SSL 도메인


## 설치 가이드
1. AWS Console에 접속해 Ansible과 Terraform을 실행할 Master Node를 생성합니다.
- Name: MasterNode
- AMI: Ubuntu Server 22.04 LTS
- Instance Type: t2.micro
- Security Group: default

2. Terraform tfstate 저장을 위한 AWS S3 Bucket을 생성합니다.
- Name: my-aws-terraform-s3-bucket

3. 생성된 EC2에 간단한 설정을 합니다
```bash
# 설치할 디렉토리 퍼미션 변경
sudo chown -R ubuntu:ubuntu /opt

# Ansible SSH HostKeyChecking 해제
sudo sed -i 's/#   StrictHostKeyChecking ask/    StrictHostKeyChecking no/g' /etc/ssh/ssh_config

# SSHD 재실행
sudo systemctl restart sshd
```

4. DevSecOps를 구축하기 위한 도구를 설치합니다.

```bash
# Git 저장소 클론
cd /opt
git clone https://github.com/ghkimdev/devsecops-installation.git
```

```
# 설치파일 위치로 이동
cd devsecops-installation/install
```
```
# 설치파일 실행
./install_ansible.sh
./install_terraform.sh
./install_awscli.sh
./install_helm.sh
./install_kubectl.sh
./install_eksctl.sh
./install_argocd.sh
```

5. AWS의 Access key와 Secret key를 설정 합니다.
```bash
# aws configure 적용
aws configure 
```
- AWS Access Key ID [None]: XXXXXXX
- AWS Secret Access Key [None]: XXXXXXXXX
- Default region name [None]: ap-northeast-2
- Default output format [None]: json

6. Terraform으로 AWS 리소스를 생성합니다.
```bash
# Terraform 실행 
cd terraform
terraform init
terraform plan
terraform apply
```

7. Terraform으로 생성된 EC2 Pulbic IP를 도메인 사이트에 가서 DNS 등록합니다.

|Type|Name|Data|TTL|
| --- | --- | --- | --- | 
| A | jenkins | xx.xx.xx.xx | 600 seconds |
| A | nexus | xx.xx.xx.xx | 600 seconds |
| A | sonarqube | xx.xx.xx.xx | 600 seconds |

8. Ansible로 Jenkins, Nexus, Sonarqube를 설치하고 ssl 적용합니다.
```bash
# Ansible 실행 
cd /opt/ansible
ansible-playbook -i /opt/ansible/aws_ec2.yml -u ubuntu --vault-password-file /opt/ansible/ansible_vault_password playbook/master-playbook.yml 
```

9. Terraform으로 설치된 EKS 클러스터의 kubeconfig를 가져옵니다.
```bash
eksctl get cluster

aws eks update-kubeconfig --region ap-northeast-2 --name example
```
10. EKS에 ArgoCD, Ingress-Nginx, Cert-Manager를 설치합니다.
```bash
# ArgoCD Helm Repo 추가
helm repo add argo https://argoproj.github.io/argo-helm

# ArgoCD 설치
helm install my-argo-cd argo/argo-cd --version 7.7.14 -n argocd --create-namespace

# Ingress Nginx Helm Repo 추가
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

# Ingress Nginx 설치
helm install my-ingress-nginx ingress-nginx/ingress-nginx --version 4.12.0 -n ingress-nginx --create-namespace

# Cert Manager Helm Repo 추가
helm repo add cert-manager https://charts.jetstack.io

# Cert Manager 설치
helm install my-cert-manager cert-manager/cert-manager --version 1.16.2 -n cert-manager --create-namespace --set installCRDs=true
```

11. ArgoCD Service Type 변경
```bash
kubectl patch svc my-argo-cd-argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}' 
```

12. ArgoCD DNS 등록

|Type|Name|Data|TTL|
| --- | --- | --- | --- | 
| CNAME | argocd | xx.xx.xx.xx | 600 seconds |

13. ArgoCD Ingress 등록
```bash
kubectl apply -f /opt/devsecops-installation/install/yaml/letsencrypt-prod.yaml
kubectl apply -f /opt/devsecops-installation/install/yaml/argocd-ingress.yaml
```
14. ArgoCD
```bash
argocd login argocd.gh-devops.site
argocd account update-password
```
