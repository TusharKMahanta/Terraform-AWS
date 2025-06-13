output "subnet_id" {
    description = "The ID of the Subnet created in the specified region."
    value       = aws_subnet.mh-subnet-rs.id
}