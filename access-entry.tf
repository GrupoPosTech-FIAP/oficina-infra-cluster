# Descobre a conta AWS atual
data "aws_caller_identity" "current" {}

locals {
  # No Learner Lab, quem roda o terraform e o kubectl e a role "voclabs".
  # O access entry exige o ARN da ROLE (arn:aws:iam:...:role/voclabs),
  # nao o ARN de sessao STS (arn:aws:sts:...:assumed-role/voclabs/...).
  lab_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/voclabs"
}

# Registra a role voclabs como acesso valido ao cluster EKS
resource "aws_eks_access_entry" "access_entry" {
  cluster_name  = aws_eks_cluster.oficina.name
  principal_arn = local.lab_role_arn
  type          = "STANDARD"
}

# Associa a politica gerenciada de admin do cluster a esse acesso
resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.oficina.name
  principal_arn = local.lab_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
