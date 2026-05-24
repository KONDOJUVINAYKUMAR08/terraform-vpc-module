output "vpc_id" {
    value = aws_vpc.this.id
}
output "vpc_cidr" {
    value = aws_vpc.this.cidr_block
}
output "public_subnet_ids" {
    value = {
        for key, subnet in aws_subnet.public :
        key => subnet.id
    }
}
output "web_subnet_ids" {
    value = {
        for key, subnet in aws_subnet.web :
        key => subnet.id
    }
}
output "app_subnet_ids" {
    value = {
        for key, subnet in aws_subnet.app :
        key => subnet.id
    }
}
output "db_subnet_ids" {
    value = {
        for key, subnet in aws_subnet.db :
        key => subnet.id
    }
}
output "internet_gateway_id" {
    value = aws_internet_gateway.this.id
}
output "nat_gateway_ids" {
    value = {
        for key, nat in aws_nat_gateway.this :
        key => nat.id
    }
}
