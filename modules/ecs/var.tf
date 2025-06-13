variable "region" {
  description = "The AWS related configuration."
  type = string 
}
variable "resource" {
  description = "The Subnet related configuration."
  type = object({
    vpc_id = string
    subnet_id = string
    tag = string
  })
}