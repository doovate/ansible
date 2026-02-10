# Proxmox variables
variable "proxmox_api_url" {
  description = "URL de la API de Proxmox"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Token ID de Proxmox"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "Token secret de Proxmox"
  type        = string
  sensitive   = true
}

# VM variables
variable "hostname" {
  description = "VM name"
  type        = string
}

variable "template" {
  description = "Template used for VM creation"
  type        = string
  default     = "ubuntu-server-2404-template-9gb"
}

variable "cpu_type" {
  description = "Type of CPU"
  type        = string
  default     = "kvm64"
}

variable "cpu_sockets" {
  description = "Number of CPU sockers"
  type        = number
  default     = 1
}

variable "numa" {
  description = "Enable NUMA"
  type        = bool
  default     = false
}

variable "datastore" {
  description = "VM datastore"
  type        = string
  default     = "local"
}

variable "os_type" {
  description = "OS type"
  type        = string
  default     = "cloud-init"
}

variable "gateway" {
  description = "Gateway"
  type        = string
  default     = "192.168.24.11"
}

variable "dns_servers" {
  description = "DNS servers list"
  type        = list(string)
  default     = ["192.168.24.60", "1.1.1.1"]
}

variable "search_domains" {
  description = "DNS domain search list"
  type        = list(string)
  default     = ["doovate.com"]
}

variable "tsg_user" {
  description = "SSH user"
  type        = string
  sensitive   = true
}

variable "tsg_password" {
  description = "SSH password"
  type        = string
  sensitive   = true
}

variable "tsg_key" {
  description = "SSH public key"
  type        = string
  sensitive   = true
}

variable "ip_forward" {
  description = "Public IP that DNS will point to"
  type        = string
  default     = "57.130.23.235"
}

variable "subdomain" {
  description = "Subdomain to be created in Cloudflare"
  type        = string
}

variable "onboot" {
  description = "Start VM when host powers on"
  type        = bool
  default     = true
}
