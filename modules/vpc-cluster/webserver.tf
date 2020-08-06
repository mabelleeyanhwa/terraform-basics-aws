//  Create the master userdata script.
data "template_file" "user_data" {
  template = file("${path.module}/files/user-data.sh")
  vars = {
    server_port = var.server_port
  }
}
data "aws_ami" "amazon-linux-2" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_launch_configuration" "cluster_node" {

  name_prefix   = "${var.env}-cluster-node-"
  image_id      = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }

  security_groups = [
    aws_security_group.private_instance.id,
    aws_security_group.public_egress.id,
    aws_security_group.intra_node_communication.id
  ]
  user_data = data.template_file.user_data.rendered
  key_name  = aws_key_pair.keypair.key_name
}

resource "aws_autoscaling_group" "cluster_node" {
  name                 = "${var.env}-cluster_node"
  min_size             = var.web_server_count
  max_size             = var.web_server_count
  desired_capacity     = var.web_server_count
  vpc_zone_identifier  = aws_subnet.private-subnet.*.id
  launch_configuration = aws_launch_configuration.cluster_node.name
  health_check_type    = "ELB"

  lifecycle {
    create_before_destroy = true
  }
}

# A load balancer for the cluster.
resource "aws_lb" "cluster-alb" {
  name               = "${var.env}-cluster-alb"
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.public_ingress.id,
    aws_security_group.intra_node_communication.id,
    aws_security_group.public_egress.id
  ]
  subnets = aws_subnet.public-subnet.*.id
}

resource "aws_lb_target_group" "asg" {
  name     = "${var.env}-asg"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.cluster.id
}

resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.cluster-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.asg.arn
    type             = "forward"
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg-attachment" {
  autoscaling_group_name = aws_autoscaling_group.cluster_node.id
  alb_target_group_arn   = aws_lb_target_group.asg.arn
}
