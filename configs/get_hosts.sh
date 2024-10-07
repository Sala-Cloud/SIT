#!/bin/bash

# get_hosts.sh
# Usage: ./get_hosts.sh inventory_file

INVENTORY_FILE=$1

# Check if the inventory file exists
if [ ! -f "$INVENTORY_FILE" ]; then
  echo "Inventory file not found: $INVENTORY_FILE"
  exit 1
fi

# Extract hosts from the inventory file
awk '/^HOST/{print $2}' "$INVENTORY_FILE" || {
  echo "Error extracting hosts from inventory file."
  exit 1
}
