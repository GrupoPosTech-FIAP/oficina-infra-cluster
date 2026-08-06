resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc_oficina.id

  route {
    cidr_block = "0.0.0.0/0" //aberto para todas as origens (internet)
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rt_association" {
  count          = 3
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.rt_public.id
}

