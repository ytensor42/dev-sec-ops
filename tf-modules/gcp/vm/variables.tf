variable "name" {
  description = "VM name"
  type        = string
}

variable "zone" {
  description = "zone"
  type        = string
  default     = "us-west1-b"
}

variable "labels" {
  description = "labels"
  type        = map
  default     = {}
}

variable "deletion_protection" {
  description = "Instance deletion protection"
  type        = bool
  default     = true
}

variable "enable_display" {
  description = "Enable display device"
  type        = bool
  default     = false
}

variable "machine_type" {
  description = "VM machine type"
  type        = string
  default     = "f1-micro"
}

variable "tags" {
  description = "VM tags"
  type        = list(string)
  default     = [ "allow-onprem-ingress", "allow-sharedvpc", "iap-ssh" ]
}

variable "resource_policies" {
  description = "Resource policy for actions"
  type        = list(string)
  default     = []
}

variable "metadata" {
  description = "metadata"
  type        = map
  default     = {}
}

variable "allow_stopping_for_update" {
  description = "Allow stopping for update"
  type        = bool
  default     = false
}

variable "reservation_affinity_type" {
  description = "Reservation type"
  type        = string
  default     = "ANY_RESERVATION"
}

variable "boot_disk_image" {
  description = "Boot disk image"
  type        = string
  default     = "ubuntu-2004-lts"
}

#locals {
#  is_windows             = substr(var.boot_disk_image, 0, 3) == "win" || substr(var.boot_disk_image, 0, 3) == "sql"
#  connection_user        = "sa_109667648326310187792"
#  connection_private_key = file("~/.ssh/id_rsa")
#  inline_key             = {
#    "ubuntu-2004-lts"    = "resolve_type_1"
#  }
#  inline                 = {
#    "resolve_type_1"     = [
#      "sudo sed -i -e 's/^#DNS=/DNS=169.254.169.254/' -e 's/^#Domains=/Domains=amyris.local/' /etc/systemd/resolved.conf",
#      "sudo systemctl restart systemd-resolved",
#    ]
#  }
#}

locals {
  is_windows  = substr(var.boot_disk_image, 0, 3) == "win" || substr(var.boot_disk_image, 0, 3) == "sql"

  startup_key = {
    "ubuntu-1804-lts" = "resolve_1"
    "ubuntu-2004-lts" = "resolve_1"
    "windows-2016"    = "null"
    "windows-2012-r2" = "null"
    "projects/de-production-456164/global/images/delphix-mgmt" = "resolve_1"
  }

  startup     = {
    "null"      = null
    "resolve_1" = <<EOF
    if [ ! -e /etc/startup-script.done ]; then
      sed -i -e 's/^#DNS=/DNS=169.254.169.254/' -e 's/^#Domains=/Domains=amyris.local/' /etc/systemd/resolved.conf
      systemctl restart systemd-resolved
      touch /etc/startup-script.done
    fi
    EOF
  }
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 40
}

variable "subnetwork" {
  description = "Subnetwork"
  type        = string
  default     = "projects/share-vpc-fca7/regions/us-west1/subnetworks/us-subnet"
}

variable "shielded_vm" {
  description = "Shielded VM"
  type        = bool
  default     = true
}

variable "enable_integrity_monitoring" {
  description = "Turn on Integrity Monitoring"
  type        = bool
  default     = true
}

variable "enable_secure_boot" {
  description = "Turn on Secure Boot"
  type        = bool
  default     = false
}

variable "enable_vtpm"{
  description = "Turn on vTPM"
  type        = bool
  default     = true
}

variable "sa_scopes" {
  description = "Compute service account scopes"
  type        = list(string)
  default     = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/trace.append",
  ]
}

variable "disks" {
  description = "Additional disks"
  type        = list
  default     = []
}

variable "dns_name" {
  description = "DNS zone name"
  type        = string
  default     = "amyris-dev"
}

variable "share_project" {
  description = "Share project ID"
  type        = string
  default     = "share-vpc-fca7"
}

variable "instance_admin" {
  description = "VM instance admin"
  type        = string
  default     = "group:gcp-devops@amyris.com"
}
