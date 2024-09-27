resource "aws_lb_target_group" "catalaogue" {
  name     = "${local.name}-${var.tags.Component}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  deregistration_delay = 60

 health_check {
      healthy_threshold   = 2
      interval            = 10
      unhealthy_threshold = 3
      timeout             = 5
      path                = "/health"
      port                = 8080
      matcher = "200-299"
 
    }

    }

module "catalaogue" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  ami = data.aws_ami.centos8.id
  name                   = "${local.name}-catalaogue"
  instance_type          = "t3.small"
  vpc_security_group_ids = [data.aws_ssm_parameter.shipping_sg_id.value]
  subnet_id              = element(split(",", data.aws_ssm_parameter.private_subnet_ids.value), 0)
  iam_instance_profile = "ShellScriptRoleForRoboshop"

  tags = merge(
    var.common_tags,
    {
      Component = "shipping"
    },
    {
      Name = "${local.name}-shipping"
    }
  )
}


resource "null_resource" "shipping" {
  # Changes to any instance of the cluster requires re-provisioning
 
   triggers = {
    instance_id = module.shipping.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.shipping.private_ip
    type = "ssh"
    user = "centos"
    password = "DevOps321"
  }


   provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

   provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh shipping dev"
    ]
  }
 }
resource "aws_ec2_instance_state" "shipping" {
  instance_id = module.shipping.id
  state       = "stopped"
  depends_on = [ null_resource.shipping ]
}

resource "aws_ami_from_instance" "shipping" {
  name               = "${local.name}-${var.tags.Component}-${local.current_time}"
  source_instance_id = module.shipping.id
  depends_on = [ aws_ec2_instance_state.shipping ]
}

resource "null_resource" "shipping_delete" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.shipping.id
  }

  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    command = "aws ec2 terminate-instances --instance-ids ${module.shipping.id}"
  }

  depends_on = [ aws_ami_from_instance.shipping]
}

resource "aws_launch_template" "shipping" {
  name = "${local.name}-${var.tags.Component}"

  image_id = aws_ami_from_instance.shipping.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  update_default_version = true

  vpc_security_group_ids = [data.aws_ssm_parameter.shipping_sg_id.value]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.name}-${var.tags.Component}"
    }
  }

}

resource "aws_autoscaling_group" "shipping" {
  name                      = "${local.name}-${var.tags.Component}"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 2
  vpc_zone_identifier       = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  target_group_arns = [ aws_lb_target_group.shipping.arn ]
  
  launch_template {
    id      = aws_launch_template.shipping.id
    version = aws_launch_template.shipping.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "${local.name}-${var.tags.Component}"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}

resource "aws_lb_listener_rule" "shipping" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shipping.arn
  }


  condition {
    host_header {
      values = ["${var.tags.Component}.app-${var.environment}.${var.zone_name}"]
    }
  }
}

resource "aws_autoscaling_policy" "shipping" {
  autoscaling_group_name = aws_autoscaling_group.shipping.name
  name                   = "${local.name}-${var.tags.Component}"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 5.0
  }
}