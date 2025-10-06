# app-terraform

## Descrição
Este projeto provisiona infraestrutura AWS utilizando Terraform para implantar uma aplicação escalável baseada em Kubernetes. Inclui um cluster Amazon EKS, integração com banco de dados RDS, AWS Cognito para autenticação de usuários e implantação de uma aplicação Spring Boot no Kubernetes com segredos gerenciados via AWS Secrets Manager. A infraestrutura é projetada para alta disponibilidade e autoescalonamento, com ingress e suporte a CORS.

## Pré-requisitos
- Terraform 1.0 ou superior
- AWS CLI configurado com credenciais e permissões adequadas
- Estado remoto do Terraform para RDS armazenado em S3 (referenciado por este projeto)
- Acesso ao AWS Secrets Manager para os segredos necessários
- kubectl configurado para interagir com o cluster EKS após a implantação

## Visão Geral da Infraestrutura
- **Cluster EKS**: Cluster Kubernetes gerenciado com um grupo de nós usando instâncias t3.medium.
- **Banco de Dados RDS**: Banco MySQL referenciado via estado remoto do Terraform.
- **AWS Cognito**: User Pool e Client para autenticação e autorização.
- **Recursos Kubernetes**:
  - Deployment da aplicação Spring Boot (`leynerbueno/tech-challenge:latest`)
  - Secret Kubernetes populado a partir do AWS Secrets Manager com credenciais do banco, email e token Mercado Pago
  - Serviço Kubernetes expondo a aplicação internamente na porta 80
  - Ingress com controlador nginx e CORS habilitado
  - Horizontal Pod Autoscaler para escalonamento dos pods baseado no uso de CPU

## Configuração
- Variáveis definidas em `variables.tf` com valores padrão:
  - `aws_region`: Região AWS (padrão: `us-east-1`)
  - `cluster_name`: Nome do cluster EKS (padrão: `techchallenge-cluster`)
- Segredos são gerenciados externamente no AWS Secrets Manager e referenciados nos Secrets do Kubernetes.
- O estado do Terraform é armazenado no bucket S3 `techchallenge-tf` na chave `eks/terraform.tfstate`.

## Instruções de Implantação
1. Inicialize o Terraform:
   ```bash
   terraform init
   ```
2. Revise as mudanças planejadas:
   ```bash
   terraform plan
   ```
3. Aplique a infraestrutura:
   ```bash
   terraform apply
   ```

## Outputs
- `cluster_name`: Nome do cluster EKS
- `cluster_endpoint`: Endpoint da API do cluster EKS
- `cluster_security_group_id`: ID do grupo de segurança do cluster EKS
- `app_service_name`: Nome do serviço Kubernetes da aplicação implantada
- `ingress_name`: Nome do recurso Ingress Kubernetes

## Detalhes da Aplicação
- Imagem do container: `leynerbueno/tech-challenge:latest`
- Variáveis de ambiente são injetadas a partir dos Secrets Kubernetes, que obtêm dados sensíveis do AWS Secrets Manager:
  - URL, usuário e senha do banco de dados
  - Usuário e senha de email
  - Token de acesso Mercado Pago

## CI/CD com GitHub Actions
- O projeto inclui um workflow do GitHub Actions (`.github/workflows/terraform.yml`) para automatizar operações do Terraform em eventos de push.
- Este workflow gerencia a inicialização, planejamento e aplicação do Terraform de forma controlada.

## Licença
Especifique a licença do projeto aqui, se aplicável.
