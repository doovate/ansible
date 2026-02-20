#!/bin/bash
ansible-inventory -i ../inv/netbox_inventory.netbox.yml --list
ansible-inventory -i ../inv/netbox_inventory.netbox.yml --graph