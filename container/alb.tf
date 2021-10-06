resource "aws_lb" "sample_alb" {
  name                       = "sample-alb"
  load_balancer_type         = "application"
  ip_address_type            = "ipv4"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = data.aws_subnet_ids.private.ids

  tags = { Name = "sample-alb" }
}

resource "aws_lb_listener" "sample_alb_listner" {
  load_balancer_arn = aws_lb.sample_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_tg.arn
    order            = 1
  }
}

resource "aws_lb_target_group" "sample_tg" {
  name                 = "sample-alb-target-group"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"

  stickiness {
    enabled         = false
    type            = "lb_cookie"
  }
  tags = { Name = "sample-alb-target-group" }
}
