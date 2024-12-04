# 1. Define provider
provider "google" {
  project = trimspace(file("../../cloud_secrets/gcp_project_id.txt"))
  region  = var.region
}

# 2. Variables
variable "region" {
  description = "Deploy region"
  default     = "europe-central2"
}

# 3. VPC
resource "google_compute_network" "vpc_network" {
  name                    = "test-vpc"
  auto_create_subnetworks  = false
}

# 4. Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "test-subnet"
  network       = google_compute_network.vpc_network.id
  region        = var.region
  ip_cidr_range = "10.0.1.0/24"
}

# 5. External IP
resource "google_compute_address" "static_ip" {
  name   = "test-vm-public-ip"
  region = var.region
}

# 6. Firewall rules
# Allow SSH (port 22)
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction   = "INGRESS"
  source_ranges = ["0.0.0.0/0"]  # Allow from any IP
}

# Allow HTTP (port 80)
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  direction   = "INGRESS"
  source_ranges = ["0.0.0.0/0"]  # Allow from any IP
  target_tags = ["http-server"]  # Matches the VM's tags
}


# 7. VM Instance (NGINX)
resource "google_compute_instance" "gcp_nginx_vm" {
  name         = "test-nginx-instance"
  machine_type = "f1-micro"
  zone         = "${var.region}-a"

  boot_disk {
    auto_delete = true
    device_name = "gcp-nginx-vm"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20241112"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = false
  deletion_protection = false
  enable_display      = false

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  metadata = {
    startup-script = "#!/bin/bash\nsudo apt update -y\nsudo apt install nginx -y\nsudo systemctl enable nginx\nsudo systemctl start nginx"
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      nat_ip = google_compute_address.static_ip.address
      network_tier = "PREMIUM"
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "818313986428-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append"
    ]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }

  tags = ["http-server"]
}
