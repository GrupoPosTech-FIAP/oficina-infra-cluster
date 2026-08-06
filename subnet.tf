resource "aws_subnet" "subnet_public" {
  count                   = 3                                                          // Cria 3 subnets
  vpc_id                  = aws_vpc.vpc_oficina.id                                     //Atrela a subnet a VPC
  cidr_block              = cidrsubnet(aws_vpc.vpc_oficina.cidr_block, 4, count.index) //Cria subnets com base no CIDR da VPC
  map_public_ip_on_launch = true                                                       //Permite que as instâncias lançadas na subnet recebam IP público
  availability_zone       = ["us-east-1a", "us-east-1b", "us-east-1c"][count.index]    //Define a zona de disponibilidade para cada subnet
  tags = merge(var.tags, {
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/eks-oficina-terraform" = "shared"
  })

}

