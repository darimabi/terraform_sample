module "vpc" {
  source          = "terraform-aws-modules/vpc/aws"
  name            = "sample-vpc"
  cidr            = var.vpc_cidr
  azs             = [data.aws_availability_zones.azs.names[0], data.aws_availability_zones.azs.names[1]]
  private_subnets = [cidrsubnet(var.vpc_cidr, 8, 3), cidrsubnet(var.vpc_cidr, 8, 4)]
  private_subnet_tags = {
    Type = "Private"
  }
  public_subnets = [cidrsubnet(var.vpc_cidr, 8, 1), cidrsubnet(var.vpc_cidr, 8, 2)]
  public_subnet_tags = {
    Type = "Public"
  }
  enable_nat_gateway           = true
  single_nat_gateway           = true
  create_database_subnet_group = true
  enable_dns_hostnames         = true
  enable_dns_support           = true

  vpc_tags = {
    Name = "sample-vpc"
  }
}

module "server" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "~> 2.0"
  name                        = "sample_server"
  ami                         = "ami-087c17d1fe0178315"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.ssh_key
  vpc_security_group_ids      = [aws_security_group.sample_server_sg.id]
  subnet_id                   = module.vpc.public_subnets[0]

  tags = {
    Name = "sample-server"
  }
}

resource "aws_security_group" "sample_server_sg" {
  description = "Security group to allow SSH from assigned IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
    description = "My IP"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ecs" {
  source = "./container"
  vpc_id = module.vpc.vpc_id
}
