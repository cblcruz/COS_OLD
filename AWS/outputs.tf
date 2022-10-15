# output "aws_vpc" {
#   value = aws_vpc.pov_vpc.id
# }

output "Leader_public_ip_address" {
  value = aws_instance.leader.public_ip
}

output "vpc_id" {
  value = aws_default_vpc.cribl_pov.id
}

output "S3_Bucket" {
  value = aws_s3_bucket.cribl-pov-bucket.bucket
}

output "Load_Balancer" {
  value = aws_elb.cibl-pov-lb.name
}

output "Satellite_Server" {
  value = aws_instance.satellite.public_ip

}
output "Workers" {
  value = ["${aws_instance.worker.*.public_ip}",
  "${aws_instance.worker.*.public_dns}"]
}
output "tls_private_key" {
  value     = ["${tls_private_key.linux_key.private_key_openssh}"]
  sensitive = true
}