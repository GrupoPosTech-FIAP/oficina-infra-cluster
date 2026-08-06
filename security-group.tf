# Security Group do RDS: controla QUEM pode falar com o banco.
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Permite acesso ao RDS PostgreSQL a partir dos nos do EKS"
  vpc_id      = aws_vpc.vpc_oficina.id

  # Entrada: porta 5432 (PostgreSQL) SOMENTE vinda do Security Group do cluster EKS.
  # Nao usamos cidr_blocks aqui de proposito: assim o banco nao fica aberto para a
  # internet, so os pods que rodam no cluster conseguem alcancar.
  ingress {
    description     = "PostgreSQL vindo dos nos do EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.oficina.vpc_config[0].cluster_security_group_id]
  }

  # Saida liberada (padrao).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
