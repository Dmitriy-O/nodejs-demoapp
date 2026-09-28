resource "aws_subnet" "documentdb_private" {
  for_each = var.enable_documentdb ? var.documentdb_subnet_cidrs : {}

  vpc_id                  = aws_vpc.application.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = {
    Name        = "${local.name_prefix}-documentdb-${each.key}"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_docdb_subnet_group" "application" {
  count = var.enable_documentdb ? 1 : 0

  name       = "${local.name_prefix}-documentdb-subnets"
  subnet_ids = [for subnet in aws_subnet.documentdb_private : subnet.id]

  tags = {
    Name        = "${local.name_prefix}-documentdb-subnets"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_security_group" "documentdb" {
  count = var.enable_documentdb ? 1 : 0

  name        = "${local.name_prefix}-documentdb-sg"
  description = "DocumentDB access from application instances"
  vpc_id      = aws_vpc.application.id

  tags = {
    Name        = "${local.name_prefix}-documentdb-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_vpc_security_group_ingress_rule" "documentdb_from_application" {
  count = var.enable_documentdb ? 1 : 0

  security_group_id            = aws_security_group.documentdb[0].id
  referenced_security_group_id = aws_security_group.application.id
  ip_protocol                  = "tcp"
  from_port                    = 27017
  to_port                      = 27017
  description                  = "MongoDB traffic from application security group"
}

resource "aws_docdb_cluster" "application" {
  count = var.enable_documentdb ? 1 : 0

  cluster_identifier          = "${local.name_prefix}-documentdb"
  engine                      = "docdb"
  engine_version              = "5.0.0"
  master_username             = "docdbadmin"
  manage_master_user_password = true

  db_subnet_group_name   = aws_docdb_subnet_group.application[0].name
  vpc_security_group_ids = [aws_security_group.documentdb[0].id]

  storage_encrypted       = true
  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = {
    Name        = "${local.name_prefix}-documentdb"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_docdb_cluster_instance" "application" {
  count = var.enable_documentdb ? 1 : 0

  identifier         = "${local.name_prefix}-documentdb-1"
  cluster_identifier = aws_docdb_cluster.application[0].id
  instance_class     = var.documentdb_instance_class

  tags = {
    Name        = "${local.name_prefix}-documentdb-1"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy" "read_documentdb_master_secret" {
  count = var.enable_documentdb ? 1 : 0

  name = "${local.name_prefix}-read-documentdb-master-secret"
  role = aws_iam_role.application.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "ReadDocumentDBMasterCredential"
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = aws_docdb_cluster.application[0].master_user_secret[0].secret_arn
    }]
  })
}
