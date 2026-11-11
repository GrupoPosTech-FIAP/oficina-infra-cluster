output "Tags" {
  value = var.tags
}

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

output "Billing_Repository_URL" {
  value = aws_ecr_repository.oficina_billing.repository_url
}

output "Inventory_Repository_URL" {
  value = aws_ecr_repository.oficina_inventory.repository_url
}

output "EKS_Cluster_Name" {
  value = aws_eks_cluster.oficina.name
}

output "EKS_Security_Group_Id" {
  value = aws_eks_cluster.oficina.vpc_config[0].cluster_security_group_id
}

output "SNS_Topic_ARNs" {
  description = "ARN do tópico de eventos de cada serviço produtor"
  value       = { for k, t in aws_sns_topic.events : k => t.arn }
}

output "SQS_Queue_URLs" {
  description = "URL da fila de cada serviço consumidor"
  value       = { for k, q in aws_sqs_queue.queue : k => q.url }
}

output "SQS_DLQ_URLs" {
  description = "URL da DLQ de cada serviço consumidor"
  value       = { for k, q in aws_sqs_queue.dlq : k => q.url }
}
