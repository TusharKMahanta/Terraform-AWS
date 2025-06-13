module "vpc-module-mumbai" {
  source = "../modules/vpc"
  region = "ap-south-1"
  resource = {
    cidr_block      = "10.0.0.0/16"
    instance_tenancy = "default"
    tag           = "mh-mumbai"
  }
}

module "vpc-module-mumbai-subnet" {
  source = "../modules/subnet"
  region = "ap-south-1"
  resource = {
    cidr_block = "10.0.0.0/24"
    vpc_id     = module.vpc-module-mumbai.vpc_id
    tag        = "mh-mumbai"
  }
}
module "ecs-module-mumbai" {
  source = "../modules/ecs"
  region = "ap-south-1"
  resource = {
    vpc_id = module.vpc-module-mumbai.vpc_id
    subnet_id = module.vpc-module-mumbai-subnet.subnet_id
    tag          = "mh-mumbai"
  } 
  
}
module "vpc-module-singapore" {
  source = "../modules/vpc"
  region = "ap-southeast-1"
  resource = {
    cidr_block      = "10.0.0.0/16"
    instance_tenancy = "default"
    tag           = "mh-singapore"
  }
}

module "vpc-module-singapore-subnet" {
  source = "../modules/subnet"
  region = "ap-southeast-1"
  resource = {
    cidr_block = "10.0.0.0/24"
    vpc_id     = module.vpc-module-singapore.vpc_id
    tag        = "mh-singapore"
  }
}

module "ecs-module-singapore" {
  source = "../modules/ecs"
  region = "ap-southeast-1"
  resource = {
    vpc_id = module.vpc-module-singapore.vpc_id
    subnet_id = module.vpc-module-singapore-subnet.subnet_id
    tag          = "mh-singapore"
  } 
}
