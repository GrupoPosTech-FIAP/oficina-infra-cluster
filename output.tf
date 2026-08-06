output "VPC_CIDR_Block" {
  value = aws_vpc.vpc_oficina.cidr_block
}

output "VPC_ID" {
  value = aws_vpc.vpc_oficina.id
}

output "SUBNET_CIDR_Block" {
  value = aws_subnet.subnet_public[*].cidr_block
}

output "SUBNET_ID" {
  value = aws_subnet.subnet_public[*].id
}

output "Repository_URL" {
  value = aws_ecr_repository.oficina_api.repository_url
}

output "DB_Endpoint" {
  value = aws_db_instance.default.address
}

output "EKS_Cluster_Name" {
  value = aws_eks_cluster.oficina.name
}