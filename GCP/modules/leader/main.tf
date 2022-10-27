resource "google_compute_firewall" "ssh" {
  name          = "ssh"
  network       = var.network
  target_tags   = ["leader"]
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

}

resource "google_compute_instance" "leader" {
  name         = "leader"
  machine_type = "e2-micro"
  tags         = ["leader"]

  metadata = {
    ssh-keys = "${var.username}:${var.ssh-key}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-focal-v20221018"
    }
  }

  network_interface {
    network = var.network
    access_config {}
  }

provisioner "remote-exec" {
    inline = ["echo 'Wait until SSH is ready'"]

    connection {
      type        = "ssh"
      user        = "${var.username}"
      private_key = file("${var.private_key_path}")
      host        = google_compute_instance.leader.network_interface.0.access_config.0.nat_ip
    }
  }
    provisioner "local-exec" {
    command = "ansible-playbook  -i ${google_compute_instance.leader.network_interface.0.access_config.0.nat_ip}, --private-key ${var.private_key_path} ../ansible/deployleader.yaml"
  }
}

output "showpath" {
  value = "${var.private_key_path}"
}