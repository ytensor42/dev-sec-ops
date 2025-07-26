output "vm" {
  value = google_compute_instance.vm
}

output "dns" {
  value = google_dns_record_set.dns
}

output "osAdminLogin" {
  value = google_compute_instance_iam_member.osAdminLogin
}

output "instanceAdmin" {
  value = google_compute_instance_iam_member.osAdminLogin
}
