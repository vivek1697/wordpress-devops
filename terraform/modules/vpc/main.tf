# first N AZs of whatever region we run in, so the module stays region-agnostic
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.name_prefix}-vpc" }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name_prefix}-igw" }
}

# public subnets: ALB and NAT
resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "${var.name_prefix}-public-${local.azs[count.index]}" }
}

# app tier: WordPress + EFS mount targets. CIDR offset by 10 to tell ranges apart
resource "aws_subnet" "private_app" {
  count = var.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = local.azs[count.index]

  tags = { Name = "${var.name_prefix}-app-${local.azs[count.index]}" }
}

# data tier: Aurora only, kept separate so it can have no internet route
resource "aws_subnet" "private_data" {
  count = var.az_count

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  availability_zone = local.azs[count.index]

  tags = { Name = "${var.name_prefix}-data-${local.azs[count.index]}" }
}

# one NAT for the demo — outbound only from private subnets, not user traffic.
# prod: one NAT per AZ to drop this SPOF
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.name_prefix}-nat-eip" }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags          = { Name = "${var.name_prefix}-nat" }

  depends_on = [aws_internet_gateway.this]
}

# public subnets -> internet via IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name_prefix}-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# app subnets -> NAT for outbound (SSM, package pulls)
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name_prefix}-app-rt" }
}

resource "aws_route" "app_nat" {
  route_table_id         = aws_route_table.app.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_route_table_association" "app" {
  count = var.az_count

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.app.id
}

# data subnets have no internet route at all — Aurora only talks inside the VPC
resource "aws_route_table" "data" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.name_prefix}-data-rt" }
}

resource "aws_route_table_association" "data" {
  count = var.az_count

  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.data.id
}
