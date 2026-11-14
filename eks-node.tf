# No EKS 1.30+ (Amazon Linux 2023), o hop limit padrão do IMDSv2 é 1, o que bloqueia Pods
# (que estão a 2 saltos de rede) de obterem as credenciais temporárias da LabRole para SNS/SQS/DynamoDB.
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "lt-eks-${var.project_name}-"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tags = var.tags
}

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.oficina.name
  node_group_name = "nodeg-${var.project_name}"
  node_role_arn   = data.aws_iam_role.lab.arn
  subnet_ids      = aws_subnet.subnet_public[*].id

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
}