resource "aws_ecr_repository" "oficina_api" {
  name                 = "oficina-api"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "oficina_billing" {
  name                 = "oficina-billing-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "oficina_inventory" {
  name                 = "oficina-inventory-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "oficina_execution" {
  name                 = "oficina-execution-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "oficina_customer" {
  name                 = "oficina-customer-service"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
