variable "region" {
  description = "The AWS related configuration."
  type = string 
}
variable "resource" {
  description = "The VPC/Subnet related configuration."
  type = object({
    cidr_block = string
    instance_tenancy = string
    tag = string
  })
}