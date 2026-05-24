variable "project_name" {
    type = string
}
variable "environment" {
    type = string
}
variable "aws_region" {
    type = string
}
variable "vpc_cidr" {
    type = string
}
variable "public_subnets" {
    type = map(object({
        cidr_block = string
        az = string
    }))
}
variable "web_subnets" {
    type = map(object({ 
        cidr_block = string
        az = string 
    }))
}
variable "app_subnets"{
    type = map(object({
        cidr_block = string
        az = string
    }))
}
variable "db_subnets" {
    type = map(object({
        cidr_block = string
        az = string
    }))
}
