variable "region" {
  description = "The AWS related configuration."
  type = string 
}
variable "resource" {
  description = "The Subnet related configuration."
  type = object({
    cidr_block = string
    vpc_id = string
    tag = string
  })
}