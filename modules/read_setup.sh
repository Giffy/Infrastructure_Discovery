#!/bin/bash
# Functions to related to load setup.ini file variables

# Location of the setup.ini file
setup_ini_file="../setup.ini"

# Function to get the value of a given section and key from setup file
# usage: get_setting_value <section> <key>
function get_setting_value()
  {
    check_if_setup_ini_exist
    local SECTION="$1"
    local KEY="$2"
    value=$(sed -n '/^\['"$SECTION"'\]/,/^\[.*\]/p' "$setup_ini_file" | awk -F "=" '/^[[:space:]]*'"$KEY"'/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')
    if [ -z "$value" ]; then
      print_error "Key $KEY not found in section [$SECTION] of file $setup_ini_file"
    else
      echo $value
    fi
  }

# Function to check if setup file exists
function check_if_setup_ini_exist()
  {
    # check if setup files exist
    if ! [ -f "$setup_ini_file" ]; then
      print_error "Setup file not found"
    fi
  }