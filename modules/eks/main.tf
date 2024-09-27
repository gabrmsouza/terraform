// definindo um security group na aws
resource "aws_security_group" "new-sg" {
  vpc_id = var.vpc_id
  // egress configura o cluster para ter acesso externo (internet)
  egress {
    from_port       = 0 // significa que todas as portas estão liberadas
    to_port         = 0
    protocol        = "-1"          // significa que todos os protocolos estão liberados
    cidr_blocks     = ["0.0.0.0/0"] // libera todos os ips
    prefix_list_ids = []
  }
  tags = {
    Name = "${var.prefix}-sg"
  }
}

// definindo um role na aws
resource "aws_iam_role" "cluster" {
  name = "${var.prefix}-${var.cluster_name}-role"
  // define uma policy para ter acesso ao service do eks
  assume_role_policy = <<POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "eks.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }  
  POLICY
}

// definindo a associação entre policy e role
resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSVPCResourceController" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

// defininado a criação do cloudwatch para logs
resource "aws_cloudwatch_log_group" "log" {
  name              = "/aws/eks-terraform-course/${var.prefix}-${var.cluster_name}/cluster"
  retention_in_days = var.retention_days
}

// definindo a criação de um cluster eks
resource "aws_eks_cluster" "cluster" {
  name                      = "${var.prefix}-${var.cluster_name}"
  role_arn                  = aws_iam_role.cluster.arn
  enabled_cluster_log_types = ["api", "audit"]

  // associando a vpc ao cluster
  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [aws_security_group.sg.id]
  }

  depends_on = [
    aws_cloudwatch_log_group.log,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
  ]
}

// define a criação do nodes no cluster
resource "aws_iam_role" "node" {
  name               = "${var.prefix}-${var.cluster_name}-role-node"
  assume_role_policy = <<POLICY
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  POLICY
}

// define policies para o node
resource "aws_iam_role_policy_attachment" "node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

// definindo o node group
resource "aws_eks_node_group" "node-1" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "node-1"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.subnet_ids
  instance_types  = ["t3.micro"] // define o tipo de instancia das maquinas do cluster

  // define as configurações de scaling dos nodes
  scaling_config {
    desired_size = var.desired_size // define a quantidade de nodes desejados
    max_size     = var.max_size     // define a quantidade maxima de nodes 
    min_size     = var.min_size     // define a quantidade minima de nodes
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
