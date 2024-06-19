resource "aws_vpc" "eks_vpc" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.vpc_tag_name
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = local.no_of_subnets
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  vpc_id                  = aws_vpc.eks_vpc.id
  availability_zone       = element(local.filtered_azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "eks-public_subnet-${aws_vpc.eks_vpc.id}-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = local.no_of_subnets
  cidr_block        = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, (count.index + local.no_of_subnets))
  vpc_id            = aws_vpc.eks_vpc.id
  availability_zone = element(local.filtered_azs, count.index)
  tags = {
    Name = "eks-private_subnet-${aws_vpc.eks_vpc.id}-${count.index + 1}"
  }
}


resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
}

data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }
  tags = {
    Name = "eks_vpc-public_route_table-${aws_vpc.eks_vpc.id}"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks-private_route_table-${aws_vpc.eks_vpc.id}"
  }
}



# Filter out the undesired availability zone
locals {
  filtered_azs       = [for az in data.aws_availability_zones.available.names : az if az != "us-east-1e"]
  no_of_subnets      = min(3, length(local.filtered_azs))
  public_subnet_ids  = aws_subnet.public_subnet.*.id
  private_subnet_ids = aws_subnet.private_subnet.*.id
  timestamp          = formatdate("YYYY-MM-DDTHH-MM-SS", timestamp())
}

resource "aws_route_table_association" "public_subnet_association" {
  count          = length(local.public_subnet_ids)
  subnet_id      = local.public_subnet_ids[count.index]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count          = length(local.private_subnet_ids)
  subnet_id      = local.private_subnet_ids[count.index]
  route_table_id = aws_route_table.private_rt.id
}

