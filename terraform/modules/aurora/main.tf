# Aurora in private subnets only
resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-aurora"
  subnet_ids = var.subnet_ids
  tags       = { Name = "${var.name_prefix}-aurora-subnets" }
}

# reachable only from the app tier on 3306, never public
resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-aurora-sg"
  description = "Allow MySQL from the app tier"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.name_prefix}-aurora-sg" }
}

resource "aws_security_group_rule" "db_ingress" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db.id
  source_security_group_id = var.allowed_security_group_ids[count.index]
  description              = "MySQL from app tier"
}

# created once in the primary; secondaries join by name. encryption set here, inherited
resource "aws_rds_global_cluster" "this" {
  count = var.is_primary ? 1 : 0

  global_cluster_identifier = var.global_cluster_identifier
  engine                    = "aurora-mysql"
  engine_version            = var.engine_version
  storage_encrypted         = true
}

locals {
  # primary references the cluster it made; secondary joins by name
  global_cluster_id = var.is_primary ? one(aws_rds_global_cluster.this[*].id) : var.global_cluster_identifier
}

# Aurora Global can't use AWS-managed passwords, so we generate + store one, read at boot
resource "random_password" "master" {
  count = var.is_primary ? 1 : 0

  length  = 24
  special = false # alphanumeric avoids quoting issues in wp-config
}

resource "aws_secretsmanager_secret" "db" {
  count = var.is_primary ? 1 : 0

  name = "${var.name_prefix}-db"
  # demo: immediate delete/recreate. prod keeps the default recovery window
  recovery_window_in_days = 0
}

# same JSON shape AWS uses, so user-data reads .password unchanged
resource "aws_secretsmanager_secret_version" "db" {
  count = var.is_primary ? 1 : 0

  secret_id = aws_secretsmanager_secret.db[0].id
  secret_string = jsonencode({
    username = var.master_username
    password = random_password.master[0].result
  })
}

# KMS keys are region-scoped, so the cross-region replica names its own region's key
data "aws_kms_alias" "rds" {
  count = var.is_primary ? 0 : 1
  name  = "alias/aws/rds"
}

resource "aws_rds_cluster" "this" {
  cluster_identifier        = "${var.name_prefix}-aurora"
  engine                    = "aurora-mysql"
  engine_version            = var.engine_version
  global_cluster_identifier = local.global_cluster_id

  # only the primary owns credentials and the initial database
  database_name   = var.is_primary ? var.database_name : null
  master_username = var.is_primary ? var.master_username : null
  master_password = var.is_primary ? random_password.master[0].result : null

  # secondary is an encrypted cross-region replica, so it names its region's key
  kms_key_id = var.is_primary ? null : data.aws_kms_alias.rds[0].target_key_arn

  # secondary takes writes locally and forwards them to the primary
  enable_global_write_forwarding = !var.is_primary

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  skip_final_snapshot = true # demo convenience; prod should snapshot on delete
}

resource "aws_rds_cluster_instance" "this" {
  count = var.instance_count

  identifier         = "${var.name_prefix}-aurora-${count.index}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
}
