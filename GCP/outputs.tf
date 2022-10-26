# output "Leader_public_ip_address" {
#   value = google_compute_instance.leader.public_ip
# }

# output "Satellite_Server" {
#   value = google_compute_instance.satellite_box.public_ip

# }
# output "Workers" {
#   value = ["${google_compute_instance.worker.*.public_ip}",
#   "${google_compute_instance.worker.*.public_dns}"]
# }
# # output "tls_private_key" {
# #   value     = ["${tls_private_key.linux_key.private_key_openssh}"]
# #   sensitive = true
# # }