resource "aws_db_subnet_group" "database" {
  name       = "oficina-db-subnet-group"
  subnet_ids = aws_subnet.subnet_public[*].id
}