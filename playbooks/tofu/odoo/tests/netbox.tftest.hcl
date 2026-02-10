variables {
  hostname  = "dv-addonstest"
  subdomain = "addonstest"
}

run "validate_vm_configuration" {
  command = plan

  assert {
    condition     = local.vm_name == "dv-addonstest"
    error_message = "vm_name test failed: expected 'dv-addonstest', got '${local.vm_name}'"
  }

  assert {
    condition     = local.vm_cluster == "dv-2"
    error_message = "vm_cluster test failed: expected 'dv-2', got '${local.vm_cluster}'"
  }

  assert {
    condition     = local.vm_vcpus == 4
    error_message = "vm_vcpus test failed: expected 4, got ${local.vm_vcpus}"
  }

  assert {
    condition     = local.vm_memory == 4096
    error_message = "vm_memory test failed: expected 4096, got ${local.vm_memory}"
  }

  assert {
    condition     = local.vm_disk_gb == 40
    error_message = "vm_disk_gb test failed: expected 40, got ${local.vm_disk_gb}"
  }

  assert {
    condition     = toset(local.vm_tag_names) == toset(["Odoo", "Test"])
    error_message = "vm_tag_names test failed: expected ['Odoo', 'Test'], got ${jsonencode(local.vm_tag_names)}"
  }
}