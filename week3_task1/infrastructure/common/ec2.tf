data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid     = "AllowEC2ToAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "application" {
  name               = "${local.name_prefix}-application-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "${local.name_prefix}-application-role"
  }
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.application.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "application" {
  name = "${local.name_prefix}-application-profile"
  role = aws_iam_role.application.name
}

resource "aws_launch_template" "nodejs" {
  name_prefix = "${local.name_prefix}-nodejs-"

  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.application.arn
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true

    security_groups = [
      aws_security_group.application.id
    ]
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "disabled"
  }

  monitoring {
    enabled = false
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.root_volume_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  user_data = base64encode(
    templatefile(
      "${path.module}/../../user_data/user_data.sh",
      {
        docker_image        = var.docker_image
        app_port            = var.app_port
        health_check_path   = var.health_check_path
        documentdb_endpoint = ""
        documentdb_port     = 27017
        documentdb_database = "todoDb"
      }
    )
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name_prefix}-nodejs-instance"
    }
  }

  tag_specifications {
    resource_type = "volume"

    tags = {
      Name = "${local.name_prefix}-nodejs-volume"
    }
  }

  tags = {
    Name = "${local.name_prefix}-nodejs-launch-template"
  }
}

resource "aws_autoscaling_group" "nodejs" {
  name = "${local.name_prefix}-nodejs-asg"

  min_size         = var.min_size
  desired_capacity = var.desired_capacity
  max_size         = var.max_size

  vpc_zone_identifier = values(aws_subnet.public)[*].id
  target_group_arns   = [aws_lb_target_group.nodejs.arn]

  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period
  default_instance_warmup   = var.default_instance_warmup

  launch_template {
    id      = aws_launch_template.nodejs.id
    version = tostring(aws_launch_template.nodejs.latest_version)
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
      instance_warmup        = var.default_instance_warmup
    }
  }

  dynamic "tag" {
    for_each = {
      Name        = "${local.name_prefix}-nodejs-instance"
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    ignore_changes = [desired_capacity]

    precondition {
      condition = (
        var.min_size <= var.desired_capacity &&
        var.desired_capacity <= var.max_size
      )

      error_message = "Expected min_size <= desired_capacity <= max_size."
    }
  }

  depends_on = [
    aws_lb_listener.public_http
  ]
}
