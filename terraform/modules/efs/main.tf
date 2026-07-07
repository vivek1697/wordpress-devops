# shared wp-content/uploads, so every instance sees the same media
resource "aws_efs_file_system" "this" {
  encrypted = true
  tags      = { Name = "${var.name_prefix}-uploads" }
}

# reachable only from the app tier on NFS (2049)
resource "aws_security_group" "efs" {
  name        = "${var.name_prefix}-efs-sg"
  description = "Allow NFS from the app tier"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.name_prefix}-efs-sg" }
}

resource "aws_security_group_rule" "nfs_ingress" {
  count = length(var.allowed_security_group_ids)

  type                     = "ingress"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs.id
  source_security_group_id = var.allowed_security_group_ids[count.index]
  description              = "NFS from app tier"
}

# one mount target per app subnet, so each AZ mounts locally
resource "aws_efs_mount_target" "this" {
  count = length(var.subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs.id]
}
