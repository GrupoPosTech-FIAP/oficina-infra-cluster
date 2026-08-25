# ☁️ Acesso ao AWS Academy Learner Lab

Guia rápido para o grupo iniciar o ambiente AWS e rodar o projeto.

## 1. O que é

O **Learner Lab** é um sandbox da AWS com orçamento virtual (~$100), sem cartão de crédito.
Cada pessoa roda no **próprio lab**, com infraestrutura isolada.

## 2. Pré-requisitos

- E-mail pessoal com o qual recebeu o e-mail.
- Convite do instrutor aceito (e-mail "Course Invitation" via Canvas).
- Senha criada no primeiro acesso.

## 3. Iniciar o laboratório

1. Acesse https://awsacademy.instructure.com/ e faça login.
2. Abra o curso **AWS Academy Learner Lab** → menu **Modules** → link **Learner Lab**.
3. Clique em **Start Lab** (canto superior direito) e aguarde a bolinha ficar **verde**.
4. Botão **AWS** (ícone de nuvem) abre o Console visual em nova aba.

## 4. Chaves para o terminal (Terraform / AWS CLI)

Clique em **AWS Details** → aba **AWS CLI** para ver as credenciais temporárias.
Cole-as no terminal **antes** de rodar o Terraform:

```bash
export AWS_ACCESS_KEY_ID="<seu_access_key>"
export AWS_SECRET_ACCESS_KEY="<seu_secret_key>"
export AWS_SESSION_TOKEN="<seu_session_token>"
```

> No PowerShell:
> ```powershell
> $env:AWS_ACCESS_KEY_ID="<seu_access_key>"
> $env:AWS_SECRET_ACCESS_KEY="<seu_secret_key>"
> $env:AWS_SESSION_TOKEN="<seu_session_token>"
> ```

Validar: `aws sts get-caller-identity`.

⚠️ As chaves **expiram a cada sessão** (máx. 4h). Ao reiniciar o lab, pegue novas chaves.

## 5. Regras de ouro

- 🛑 **End Lab** ao terminar — evita consumir crédito.
- 🧹 **`terraform destroy`** no fim do dia para apagar recursos pesados.
- 🌎 Região fixa: **us-east-1** (Norte da Virgínia).
- 🚫 Serviços caros/avançados podem dar **Access Denied** no perfil de estudante.
