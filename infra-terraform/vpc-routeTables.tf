resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.env}-private-route-table"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.env}-public-route-table"
  }
}

resource "aws_route_table_association" "private_sub1" {
  subnet_id      = aws_subnet.private_sub1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_sub2" {
  subnet_id      = aws_subnet.private_sub2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_sub1" {
  subnet_id      = aws_subnet.public_sub1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_sub2" {
  subnet_id      = aws_subnet.public_sub2.id
  route_table_id = aws_route_table.public.id
}