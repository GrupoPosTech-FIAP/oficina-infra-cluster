variable "cidr_vpc" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  default = {
    Name = "oficina-terraform"
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "oficina-terraform"
}
variable "messaging_max_receive_count" {
  description = "Tentativas de processamento antes de a mensagem ir para a DLQ"
  type        = number
  default     = 5
}
