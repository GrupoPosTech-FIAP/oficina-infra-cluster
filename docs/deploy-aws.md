# 🚀 Provisionamento da Infraestrutura na AWS (EKS + ECR + Rede)

Guia para provisionar a infraestrutura base do cluster utilizando Terraform. Este repositório
é responsável pela **rede (VPC, Subnets, Internet Gateway, Rotas)**, pelo **cluster EKS** e
pelo **repositório de imagens (ECR)**.

> O banco de dados (RDS) é gerenciado em um repositório separado: `oficina-infra-database`.
> O deploy da aplicação em si é feito pelo repositório `Tech-Challenge-15SOAT`.

> As credenciais do Learner Lab expiram a cada sessão (máx. 4h). Antes de continuar,
> consulte [acesso-aws-learner-lab.md](acesso-aws-learner-lab.md) para iniciar o lab e
> exportar as chaves. **Faça isso antes** dos passos abaixo.

### Pré-requisitos
- AWS CLI e Terraform instalados.
- Lab iniciado e credenciais exportadas.
- Validar: `aws sts get-caller-identity`.

---

## 1 — Criar o bucket S3 para o estado do Terraform

O Terraform precisa de um bucket S3 para armazenar o `terraform.tfstate` — o arquivo que
rastreia tudo que foi criado na AWS. Ele deve existir **antes** do `terraform init`.

> O nome do bucket é **globalmente único** na AWS. Use um sufixo pessoal para garantir unicidade
> (ex: seu usuário ou matrícula). Apenas letras minúsculas, números e hífens são permitidos.

```bash
aws s3api create-bucket \
  --bucket oficina-tfstate-SEU-NOME \
  --region us-east-1
```

Guarde o nome escolhido — você vai usá-lo nos próximos passos e também como input na pipeline
do GitHub Actions (`TF_BUCKET_NAME`).

> ⚠️ O bucket **não** é destruído pelo `terraform destroy`, pois ele não é gerenciado por este
> código Terraform. Apague-o manualmente pelo Console da AWS ou via CLI se não for mais usar.

---

## 2 — Provisionar a infraestrutura

```bash
# Na raiz deste repositório
terraform init -backend-config="bucket=oficina-tfstate-SEU-NOME"
terraform plan
terraform apply        # ~10-15 min (o EKS é lento)
```

> ⚠️ Particularidade do Learner Lab: não é possível criar IAM Roles. O Terraform
> usa a role pré-existente **`LabRole`** (ver [`iam-role.tf`](../iam-role.tf)).

Ao terminar, anote os outputs (`terraform output`) — eles serão usados pelos outros repositórios:

| Output              | Descrição                                         | Usado em                        |
|---------------------|---------------------------------------------------|---------------------------------|
| `EKS_Cluster_Name`  | Nome do cluster (`eks-oficina-terraform`)         | Deploy da aplicação (kubeconfig)|
| `Repository_URL`    | URL do repositório ECR                            | Build e push da imagem Docker   |
| `EKS_Security_Group_Id` | ID do Security Group do cluster              | Infra do banco de dados (RDS SG)|
| `VPC_ID`            | ID da VPC criada                                  | Infra do banco de dados (Subnet)|
| `SUBNET_ID`         | IDs das subnets públicas                          | Infra do banco de dados (RDS SG)|

## 3 — Verificar o cluster

Após o `apply`, confirme que o cluster está operacional:

```bash
aws eks update-kubeconfig --name eks-oficina-terraform --region us-east-1
kubectl config current-context   # deve apontar para eks-oficina-terraform
kubectl get nodes                # nó(s) devem aparecer como Ready
```

---

## 4 — Encerrar (evita consumir crédito)

```bash
terraform destroy    # apaga EKS, ECR, VPC e todos os recursos gerenciados aqui
```
E clique em **End Lab** no Learner Lab.

> ⚠️ Destrua a infra **antes** de encerrar o lab. Recursos esquecidos consomem o saldo virtual.

---

## Troubleshooting

| Sintoma | Causa provável | Correção |
|---|---|---|
| `AccessDenied ... voc-cancel-cred` | Credenciais de sessão expirada | Start Lab + reexportar as chaves ([acesso-aws-learner-lab.md](acesso-aws-learner-lab.md)) |
| `no such host` no `kubectl` local | Cluster recriado → endpoint do EKS mudou | `aws eks update-kubeconfig --name eks-oficina-terraform --region us-east-1` |
| `Error: Cannot create IAM Role` | Learner Lab não permite criar Roles | Confirme que `iam-role.tf` usa `data` (leitura da `LabRole`) e não `resource` |
| `kubectl get nodes` — nenhum nó `Ready` | Node group ainda provisionando | Aguarde ~5 min e tente novamente |

> 💡 **Regra de ouro do Learner Lab:** toda recriação da infra muda o endpoint do EKS.
> Sempre rode `aws eks update-kubeconfig` após um novo `terraform apply`.
