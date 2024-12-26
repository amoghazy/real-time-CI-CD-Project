resource "aws_subnet" "private_sub1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = local.zone1

  tags = {
    "Name"         = "${local.env}-private-${local.zone1}"

  }
}

resource "aws_subnet" "private_sub2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = local.zone2

  tags = {
    "Name"         = "${local.env}-private-${local.zone2}"

  }
}

resource "aws_subnet" "public_sub1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = local.zone1
  map_public_ip_on_launch = true

  tags = {
    "Name"         = "${local.env}-public-${local.zone1}"
 
  }
}

resource "aws_subnet" "public_sub2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = local.zone2
  map_public_ip_on_launch = true

  tags = {
    "Name"         = "${local.env}-public-${local.zone2}"

  }
}