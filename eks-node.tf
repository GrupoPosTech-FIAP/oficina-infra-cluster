resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.oficina.name
  node_group_name = "nodeg-${var.project_name}"
  node_role_arn   = data.aws_iam_role.lab.arn
  subnet_ids      = aws_subnet.subnet_public[*].id

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
}