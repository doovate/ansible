terraform {
  required_version = ">= 1.8"

  backend "s3" {
    bucket = "terra-savings"
    key    = "odoo/${var.hostname}/terraform.tfstate"
    region = "eu-west-par"
    endpoints = {
      s3 = "https://s3.eu-west-par.io.cloud.ovh.net"
    }
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true
  }

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc04"
    }
    netbox = {
      source  = "e-breuninger/netbox"
      version = "~> 5.1.0"
    }
  }
}

provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}

provider "netbox" {
  server_url = "http://192.168.24.55:9100"
  api_token  = "afce2096a1a4ba342c98d579fac45f9befe83461"
}