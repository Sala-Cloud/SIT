#!/bin/bash

# Check if the inventory file is provided
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <inventory_file>"
  exit 1
fi

# Extract IPs/hosts from the inventory file
grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$1" | awk '{print $1}' | sort -u
