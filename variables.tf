variable "vm_ssh_public_key" {
  type        = string
  description = "SSH public key for the virtual machines"
}

variable "admin_ip" {
  type        = string
  description = "Public IP/CIDR allowed to SSH to the jumpbox"
} 