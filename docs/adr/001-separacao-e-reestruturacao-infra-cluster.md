# Título: Separação da infraestrutura do cluster e reestruturação do repositório

## Resumo
Extração dos recursos de rede (VPC), cluster Kubernetes (EKS) e registro de imagens (ECR)
do repositório monolítico `Tech-Challenge-15SOAT` para um repositório dedicado
`oficina-infra-cluster`, com ajustes técnicos, documentação e correções de configuração
para que o repositório seja autossuficiente e bem documentado.

---

## Problema
O repositório original (`Tech-Challenge-15SOAT`) concentrava em uma única pasta `infra/`
todos os recursos de infraestrutura — rede, cluster, banco de dados e registro de imagens.
Isso gerava os seguintes problemas:

- **Acoplamento total:** qualquer mudança na rede, no cluster ou no banco exigia rodar o
  `terraform apply` de toda a pilha, sem isolamento de responsabilidade.
- **Repositório de aplicação com responsabilidade de infraestrutura:** código Java, Dockerfile,
  manifestos Kubernetes e Terraform coexistiam no mesmo repositório, violando o princípio de
  separação de responsabilidades.
- **Key de state genérica e potencialmente conflitante:** o `backend.tf` original usava
  `key = "global/s3/terraform.tfstate"` — um nome genérico que não refletia qual parte da
  infra estava sendo gerenciada e causaria conflito caso outros módulos Terraform
  compartilhassem o mesmo bucket S3.
- **Ausência de README:** o repositório recém-criado não tinha documentação de propósito,
  tecnologias, instruções de uso ou guia do pipeline.
- **Arquivo `.idea/` versionado:** a pasta de configurações locais do IntelliJ IDEA estava
  sendo rastreada pelo Git, poluindo o histórico com arquivos específicos de ambiente pessoal.
- **Documentação herdada fora de escopo:** o arquivo `docs/deploy-aws.md` foi copiado
  integralmente do repositório de origem e continha seções sobre push de imagem Docker,
  deploy de pods via Kustomize e acesso à API — conteúdo que pertence ao repositório da
  aplicação, não ao de infraestrutura.

---

## Proposta técnica
As seguintes alterações foram realizadas neste repositório:

**1. Correção da key do backend S3 (`backend.tf`)**
A key foi alterada de `"global/s3/terraform.tfstate"` para `"cluster/s3/terraform.tfstate"`,
tornando o caminho do state descritivo e isolado. Isso é fundamental para que o repositório
`oficina-infra-database` consiga ler os outputs deste cluster via `terraform_remote_state`
apontando para a key correta.

**2. Adição do `.idea/` ao `.gitignore`**
A pasta `.idea/` (gerada automaticamente pelo IntelliJ IDEA e demais IDEs da JetBrains)
foi adicionada ao `.gitignore` para evitar que configurações locais de IDE sejam versionadas.
Como o arquivo já havia sido commitado anteriormente, o rastreamento deve ser removido com
`git rm -r --cached .idea/`.

**3. Criação do `README.md`**
Criado o arquivo `README.md` na raiz do repositório com:
- Descrição do propósito e escopo do repositório.
- Referências à documentação existente na pasta `docs/`.
- Mini-guia do pipeline GitHub Actions: o que cada step faz e o roteiro seguro para
  disparar o workflow sem erros de credenciais expiradas do Learner Lab.

**4. Reescrita do `docs/deploy-aws.md`**
O arquivo foi reescrito do zero para cobrir **apenas** o que é responsabilidade deste
repositório. As seções removidas foram:
- Push de imagem Docker no ECR (responsabilidade do `Tech-Challenge-15SOAT`).
- Ajuste do overlay Kustomize e deploy dos pods via `kubectl apply` (idem).
- Acesso à API, Swagger e login (idem).
- Roteiro de teste ponta a ponta (misturava infra + aplicação).
- Seção de encerramento que mencionava `kubectl delete` e `RDS` (fora de escopo).

O arquivo mantido contempla: criação do bucket S3, `terraform init/plan/apply`,
verificação do cluster com `kubectl get nodes`, encerramento seguro e troubleshooting
focado em erros de Terraform e cluster.

**5. Adição do passo de criação do bucket S3 à documentação**
O `docs/deploy-aws.md` ganhou uma Seção 1 dedicada à criação do bucket S3 via AWS CLI,
explicando unicidade de nomes, regras de formatação e o aviso de que o bucket **não** é
destruído pelo `terraform destroy`.

---

## Impacto esperado

**Ganhos:**
- Ciclo de vida isolado: o cluster pode ser provisionado, atualizado e destruído sem
  interferir no banco de dados ou na aplicação.
- State S3 com key descritiva (`cluster/`), habilitando o `oficina-infra-database` a ler
  os outputs via `terraform_remote_state` de forma confiável.
- Documentação clara e focada, sem ruído de outras responsabilidades.
- Repositório limpo de artefatos de IDE locais.

**Riscos e restrições:**
- A mudança da key do backend (`global` → `cluster`) é uma operação destrutiva para o
  state remoto: caso o state já existisse em `global/s3/...` antes desta mudança, é
  necessário migrá-lo manualmente ou rodar `terraform init -reconfigure` para recriar.
- A ordem de provisionamento entre repositórios é obrigatória:
  `oficina-infra-cluster` deve ser aplicado antes do `oficina-infra-database`.
- As credenciais do Learner Lab expiram em ~4h, exigindo atualização manual dos secrets
  de AWS no GitHub antes de cada execução do pipeline.

---

## Alternativas consideradas

- **Manter um único repositório monolítico de infra:** descartado pela dificuldade de
  evolução independente de cluster e banco, que possuem ciclos de vida distintos.
- **Usar key `"global/s3/terraform.tfstate"` com prefixo de workspace do Terraform:**
  descartado por adicionar complexidade desnecessária (workspaces) quando a separação
  por repositório já resolve o problema de isolamento.
- **Manter a documentação completa de deploy ponta a ponta neste repositório:**
  descartado pois misturava responsabilidades e aumentava o esforço de manutenção quando
  a aplicação evoluir independentemente.

---

## Pontos em aberto
- Avaliar a automação da cadeia de deploy via `repository_dispatch` do GitHub Actions,
  permitindo que o término do apply do cluster dispare automaticamente o pipeline do banco
  de dados, passando os outputs como payload.
- Avaliar adicionar um step de `terraform plan` antes do `apply` no workflow de CI/CD
  do cluster (atualmente vai direto para o `apply`), para maior controle e revisão.
- Verificar se o arquivo `.idea/` já foi commitado no histórico e, se sim, executar
  `git rm -r --cached .idea/` seguido de um commit de limpeza.
