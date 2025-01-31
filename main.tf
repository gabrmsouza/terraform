terraform {
  // define a versão minima do terraform
  required_version = ">=0.13.1"

  // define a versão minima para os providers utilizados
  required_providers {
    aws   = ">=3.54.0"
    local = ">=2.1.0"
  }

  // define um bucket remoto para armazenar o arquivo de estado do terraform
  backend "s3" {
    bucket = "myfcbucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}


// define os modulos e suas variaveis
module "new-vpc" {
  source         = "./modules/vpc"
  prefix         = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
}

module "eks" {
  source         = "./modules/eks"
  prefix         = var.prefix
  vpc_id         = module.new-vpc.vpc_id
  cluster_name   = var.cluster_name
  retention_days = var.retention_days
  subnet_ids     = module.new-vpc.subnet_ids
  desired_size   = var.desired_size
  max_size       = var.max_size
  min_size       = var.min_size
}
