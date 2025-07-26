data "google_compute_default_service_account" "sa" {
}

resource "google_compute_instance" "vm" {
  name                      = var.name
  zone                      = var.zone
  labels                    = var.labels
  deletion_protection       = var.deletion_protection
  enable_display            = var.enable_display
  machine_type              = var.machine_type
  tags                      = var.tags
  resource_policies         = var.resource_policies
  metadata                  = merge( var.metadata, local.is_windows ? {}:{ startup-script = local.startup[ local.startup_key [ var.boot_disk_image ] ] } )
  allow_stopping_for_update = var.allow_stopping_for_update

  dynamic "reservation_affinity" {
    for_each = var.reservation_affinity_type != null ? [1]:[]
    content {
      type = var.reservation_affinity_type
    }
  }

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
    }
  }

  network_interface {
    subnetwork = var.subnetwork
  }

  dynamic "shielded_instance_config" {
    for_each = var.shielded_vm ? [1]:[]
    content {
      enable_integrity_monitoring = var.enable_integrity_monitoring
      enable_secure_boot          = var.enable_secure_boot
      enable_vtpm                 = var.enable_vtpm
    }
  }

  service_account {
    email  = data.google_compute_default_service_account.sa.email
    scopes = var.sa_scopes
  }

#  connection {
#    type        = "ssh"
#    user        = local.connection_user
#    host        = self.network_interface.0.network_ip
#    private_key = local.connection_private_key
#  }

#  provisioner "remote-exec" {
#    inline = local.inline[ local.inline_key[ var.boot_disk_image ] ]
#  }

  lifecycle {
    ignore_changes = [ attached_disk ]
  }
}

resource "google_compute_disk" "disk" {
  count = length(var.disks)
  name  = var.disks[count.index].name
  type  = var.disks[count.index].type
  size  = var.disks[count.index].size
  zone  = var.zone
}

resource "google_compute_attached_disk" "attach" {
  count       = length(var.disks)
  disk        = google_compute_disk.disk[count.index].id
  instance    = google_compute_instance.vm.id
  device_name = var.disks[count.index].name
}

data "google_dns_managed_zone" "dns_zone" {
  name    = var.dns_name
  project = var.share_project
}

resource "google_dns_record_set" "dns" {
  project      = var.share_project
  name         = "${google_compute_instance.vm.name}.${data.google_dns_managed_zone.dns_zone.dns_name}"
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  type         = "A"
  ttl          = 300
  rrdatas      = [ google_compute_instance.vm.network_interface.0.network_ip ]
}

resource "google_compute_instance_iam_member" "osAdminLogin" {
  project       = google_compute_instance.vm.project
  zone          = var.zone
  instance_name = google_compute_instance.vm.name
  role          = "roles/compute.osAdminLogin"
  member        = var.instance_admin
}

resource "google_compute_instance_iam_member" "instanceAdmin" {
  project       = google_compute_instance.vm.project
  zone          = var.zone
  instance_name = google_compute_instance.vm.name
  role          = "roles/compute.instanceAdmin"
  member        = var.instance_admin
}

# Each project has a compute user group. These role should be given to the group instead.
#
# resource "google_project_iam_member" "serviceAccountUser" {
#   project = google_compute_instance.vm.project
#   role    = "roles/iam.serviceAccountUser"
#   member  = var.instance_admin
# }
#
# resource "google_project_iam_member" "networkUser" {
#   project = google_compute_instance.vm.project
#   role    = "roles/compute.networkUser"
#   member  = var.instance_admin
# }
#
# resource "google_project_iam_member" "tunnelResourceAccessor" {
#   project = google_compute_instance.vm.project
#   role    = "roles/iap.tunnelResourceAccessor"
#   member  = var.instance_admin
# }
