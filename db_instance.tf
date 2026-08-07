resource "aws_db_instance" "default" {
  allocated_storage      = 20
  db_name                = "oficina_db"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  username               = "postgres"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false

  manage_master_user_password = true
}