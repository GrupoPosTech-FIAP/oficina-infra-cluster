# Oficina - Infraestrutura do Cluster (EKS & Rede)

Este repositório é responsável por provisionar a infraestrutura base de rede e o cluster Kubernetes (EKS) na AWS utilizando Terraform. 

> **Nota:** A infraestrutura de banco de dados (RDS) foi extraída e possui um repositório próprio.

## 📚 Documentação

Para mais detalhes sobre o acesso e o processo de deploy na AWS, consulte os guias disponíveis na pasta [`docs/`](docs/):

- 🔑 **[Acesso AWS Learner Lab](docs/acesso-aws-learner-lab.md):** Um guia passo a passo explicando como iniciar a sessão do Learner Lab, obter e configurar suas credenciais (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN`). Este é o passo fundamental antes de tentar rodar o Terraform localmente ou pelo GitHub Actions.
- 🚀 **[Deploy AWS (Terraform)](docs/deploy-aws.md):** Manual com instruções e comandos focados na criação da arquitetura AWS (VPC, Subnets, ECR e cluster EKS). *Nota: este arquivo originalmente explicava o deploy completo da aplicação; aqui ele serve como referência dos recursos gerados pelo Terraform.*

---

## 🔁 CI/CD via GitHub Actions (Mini-guia)

A subida da infraestrutura está automatizada no GitHub Actions. Diferente de um fluxo normal (onde o deploy ocorre a cada `push` na main), o pipeline de infraestrutura foi configurado para ser executado **manualmente (workflow_dispatch)**. Isso acontece porque o AWS Learner Lab expira a cada ~4 horas, exigindo a atualização constante das credenciais antes de rodar o Terraform.

### Como o Workflow opera?

Localizado em [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml), ele faz os seguintes passos sob o capô:
1. **Configuração de Credenciais:** Conecta-se à AWS utilizando os *Secrets* do seu repositório GitHub.
2. **Setup do Terraform:** Instala os binários do HashiCorp.
3. **Terraform Init:** Inicia o diretório, conectando com o bucket S3 (cujo nome você passa na hora de dar "Play") para guardar o `terraform.tfstate`.
4. **Terraform Apply:** Aplica todas as definições `*.tf` da pasta criando os componentes (com flag `-auto-approve`).

### Roteiro para executar a Pipeline

Para evitar falhas de credenciais inspiradas (`AccessDenied ... explicit deny ... voc-cancel-cred`), siga religiosamente a ordem abaixo:

1. Inicie a sessão no **AWS Learner Lab** e aguarde ficar verde (Ativo).
2. Vá nas configurações do seu repositório no GitHub (**Settings > Secrets and variables > Actions**) e **atualize os 3 Secrets** (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_SESSION_TOKEN`) com as novas chaves da sua sessão.
3. Vá para a aba **Actions** e selecione o workflow **Terraform - CI/CD** na barra lateral.
4. Clique no botão **Run workflow** (lado direito).
5. No campo `TF_BUCKET_NAME`, digite o nome do bucket S3 da AWS que você vai usar para armazenar o estado do Terraform.
6. Confirme a execução e assista aos logs de criação da infraestrutura!
