#!/bin/bash

# get_hosts.sh
# Usage: ./get_hosts.sh inventory_file

INVENTORY_FILE=$1

# Check if the inventory file exists
if [ ! -f "$INVENTORY_FILE" ]; then
    echo "Inventory file not found!"
    exit 1
fi

# Extract hosts from the inventory file (Assuming the format allows for this)
# Modify the extraction command according to your inventory file structure
awk '/^HOST/{print $2}' "$INVENTORY_FILE"
