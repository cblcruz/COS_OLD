#Create the LB

resource "aws_elb" "cibl-pov-lb" {
  name               = "cribl-pov-lb"
  availability_zones = ["us-west-2a", "us-west-2b"]

  listener {
    instance_port     = 4200
    instance_protocol = "tcp"
    lb_port           = 4200
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 9514
    instance_protocol = "tcp"
    lb_port           = 9514
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 5
    timeout             = 3
    target              = "http:9000/api/"
  }

  #ELB Attachements 
  instances                 = aws_instance.worker.*.id
  cross_zone_load_balancing = true
  idle_timeout              = 40
  tags = {
    "Name" = "Cribl_POV_LB"
  }
}