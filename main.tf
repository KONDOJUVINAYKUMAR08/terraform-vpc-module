resource "aws_vpc" "this" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
        Name = "${var.project_name}-${var.environment}-vpc"
        Environment = var.environment 
    }
}

resource "aws_internet_gateway" "this" {
    vpc_id = aws_vpc.this.id

    tags = {
        Name = "${var.project_name}-${var.environment}-igw"
        Environment = var.environment
    }
}

resource "aws_subnet" "public" {
    for_each = var.public_subnets

    vpc_id = aws_vpc.this.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.project_name}-${var.environment}-public-${each.key}"
        Type = "Public"
    }
}

resource "aws_subnet" "web" {
    for_each = var.web_subnets

    vpc_id = aws_vpc.this.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az

    tags = {
        Name = "${var.project_name}-${var.environment}-web-${each.key}"
        Type = "Web-Private"
    }
}

resource "aws_subnet" "app" {
    for_each = var.app_subnets

    vpc_id = aws_vpc.this.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az

    tags = {
        Name = "${var.project_name}-${var.environment}-app-${each.key}"
        Type = "App-Private"
    }
}

resource "aws_subnet" "db" {
    for_each = var.db_subnets

    vpc_id = aws_vpc.this.id
    cidr_block = each.value.cidr_block
    availability_zone = each.value.az

    tags = {
        Name = "${var.project_name}-${var.environment}-db-${each.key}"
        Type = "DB-Private"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }

    tags = {
        Name = "${var.project_name}-${var.environment}-public-rt"
    }
}

resource "aws_route_table_association" "public" {
    for_each = aws_subnet.public

    subnet_id = each.value.id
    route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
    for_each = var.public_subnets

    domain = "vpc"

    tags = {
        Name = "${var.project_name}-${var.environment}-${each.key}-eip"
    }
}

resource "aws_nat_gateway" "this" {
    for_each = aws_subnet.public

    allocation_id = aws_eip.nat[each.key].id
    subnet_id = each.value.id

    tags = {
        Name = "${var.project_name}-${var.environment}-${each.key}-nat"
    }
    depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.this

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-${each.key}-private-rt"
  }
}

resource "aws_route_table_association" "web" {
  for_each = aws_subnet.web

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "app" {
  for_each = aws_subnet.app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_route_table_association" "db" {
  for_each = aws_subnet.db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}