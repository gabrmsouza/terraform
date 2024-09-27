// definindo a criação de uma nova vpc na aws
resource "aws_vpc" "new-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

// consumindo as zonas de disponibilidade da aws
data "aws_availability_zones" "available" {
}

# output "az" {
#   value = "${data.aws_availability_zones.available.names}"
# }

// definindo a criação das subnet na aws de forma dinamica
resource "aws_subnet" "subnets" {
  // indica para o terraform a quantidade de subnetes a serem criadas
  count = 2

  // associa as subnets a vpc
  vpc_id     = aws_vpc.new-vpc.id
  cidr_block = "10.0.${count.index}.0/24"

  // associa as subnets as zonas de disponibilidades dinamicamente
  availability_zone = data.aws_availability_zones.available.names[count.index]

  // gera um ip publico para todo recurso dentro das subnets
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet-${count.index}"
  }
}

// definindo a criação de uma internet gateway na aws para acesso externo
resource "aws_internet_gateway" "new-igw" {
  // associa o gateway a vpc
  vpc_id = aws_vpc.new-vpc.id
  tags = {
    Name = "${var.prefix}-igw"
  }
}

// definindo a criação de uma route table na aws
// tudo que estiver associado a essa route table vai ter acesso
// a internet
resource "aws_route_table" "new-rtb" {
  // associa o route table a vpc
  vpc_id = aws_vpc.new-vpc.id
  route = {
    // associando o internet gateway
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new-igw.id
  }
  tags = {
    Name = "${var.prefix}-rtb"
  }
}

// associando as subnets na route table
resource "aws_route_table_association" "new-rtb-association" {
  count          = 2
  route_table_id = aws_route_table.new-rtb.id
  subnet_id      = aws_subnet.subnets.*.id[count.index] // pega os ids dinamicamente
}

# resource "aws_subnet" "subnet-1" {
#   // associa subnet a vpc
#   vpc_id = aws_vpc.new-vpc.id
#   cidr_block = "10.0.0.0/24"
#   // associa a subnet a zonas de disponibilidade
#   availability_zone = "us-east-1a"
#   // gera um ip publico para todo recurso dentro das subnets
#   map_public_ip_on_launch = true
#   tags = {
#     Name = "${var.prefix}-subnet-1"
#   }
# }
