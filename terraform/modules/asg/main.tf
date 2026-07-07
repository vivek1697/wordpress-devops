# HTTP in only from the ALB; egress open (DB, NAT, AWS APIs)
resource "aws_security_group" "app" {
  name        = "${var.name_prefix}-app-sg"
  description = "WordPress instances"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.name_prefix}-app-sg" }
}

resource "aws_security_group_rule" "http_from_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = var.alb_security_group_id
  security_group_id        = aws_security_group.app.id
  description              = "HTTP from ALB"
}

resource "aws_security_group_rule" "app_all_out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
  description       = "Outbound to DB, NAT and AWS APIs"
}

# instance role gives SSM access — no SSH, no bastion
data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name_prefix}-wp-role"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# read only the one DB secret
resource "aws_iam_role_policy" "read_db_secret" {
  name = "${var.name_prefix}-read-db-secret"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = var.db_secret_arn
    }]
  })
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name_prefix}-wp-profile"
  role = aws_iam_role.this.name
}

resource "aws_launch_template" "this" {
  name_prefix            = "${var.name_prefix}-wp-"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app.id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  user_data = base64encode(templatefile("${path.module}/user-data.sh.tftpl", {
    db_host       = var.db_host
    db_name       = var.db_name
    db_user       = var.db_user
    db_secret_arn = var.db_secret_arn
    efs_dns_name  = var.efs_dns_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.name_prefix}-wp" }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "${var.name_prefix}-wp-asg"
  vpc_zone_identifier = var.private_subnet_ids
  target_group_arns   = var.target_group_arns

  # let the ALB decide health, not just EC2 status checks
  health_check_type         = "ELB"
  health_check_grace_period = 300

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
    # scaling policy owns capacity after launch, so don't fight it
    ignore_changes = [desired_capacity]
  }
}

# scale to hold average CPU near the target
resource "aws_autoscaling_policy" "cpu" {
  name                   = "${var.name_prefix}-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = var.cpu_target
  }
}
