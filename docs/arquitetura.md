# 🏛️ Arquitetura — oficina-infra-cluster

Este repositório provisiona a camada base de rede e computação na AWS via Terraform.

## Recursos provisionados

```mermaid
graph TD
    subgraph AWS["☁️ AWS us-east-1"]
        subgraph VPC["🔒 VPC 10.0.0.0/16"]
            IGW["🌐 Internet Gateway"]
            RT["📋 Route Table\n(0.0.0.0/0 → IGW)"]

            subgraph SUBNETS["Subnets Públicas"]
                S1["Subnet 1\nus-east-1a\n10.0.0.0/20"]
                S2["Subnet 2\nus-east-1b\n10.0.16.0/20"]
                S3["Subnet 3\nus-east-1c\n10.0.32.0/20"]
            end

            subgraph EKS["🖥️ Cluster EKS"]
                CTRL["Control Plane\neks-oficina-terraform\nv1.35"]
                NG["Node Group\nManaged (t3.medium)"]
                SG["🔒 Security Group do Cluster"]
            end
        end

        ECR["📦 ECR\noficina-api\n(IMMUTABLE)"]

        S3_STATE["🪣 S3 State\ncluster/s3/terraform.tfstate"]
    end

    IGW --> RT
    RT --> S1
    RT --> S2
    RT --> S3
    S1 --> EKS
    S2 --> EKS
    S3 --> EKS

    style VPC fill:#e3f2fd,stroke:#1565c0
    style EKS fill:#4361ee,color:#fff
    style ECR fill:#4361ee,color:#fff
    style SG fill:#bbdefb,stroke:#1565c0
```

## Outputs exportados

Estes valores são consumidos por outros repositórios via `terraform_remote_state`:

| Output | Descrição | Consumido por |
|---|---|---|
| `VPC_ID` | ID da VPC | `oficina-infra-database`, `oficina-auth-gateway` |
| `SUBNET_ID` | IDs das 3 subnets públicas | `oficina-infra-database`, `oficina-auth-gateway` |
| `SUBNET_CIDR_Block` | CIDRs das subnets | — |
| `EKS_Cluster_Name` | `eks-oficina-terraform` | `oficina-app-api` (kubeconfig) |
| `EKS_Security_Group_Id` | SG do cluster | `oficina-infra-database` (RDS ingress) |
| `Repository_URL` | URL do ECR | `oficina-app-api` (push de imagem) |
| `Tags` | Tags padrão do projeto | `oficina-infra-database` |

## Dependências

- **Pré-requisito:** Bucket S3 criado manualmente para armazenar o `terraform.tfstate`.
- **Dependentes:** `oficina-infra-database` e `oficina-auth-gateway` leem os outputs deste repositório via remote state.
- **IAM:** Usa a role pré-existente `LabRole` do AWS Academy (ver `iam-role.tf` — data source, não resource).
