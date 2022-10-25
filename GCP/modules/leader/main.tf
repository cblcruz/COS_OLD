resource "google_compute_instance" "leader" {
  name         = "leader"
  machine_type = "e2-micro"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-focal-v20221018"
    }
  }

network_interface {
  network = "default"
  access_config {}
}

}