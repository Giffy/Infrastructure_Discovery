#!/bin/bash
# Function to control error management


function print_error() {
  # Set error color
  error=$(tput setaf 1)
  reset=$(tput sgr0)


  # Print error message
  echo -e "${error}[ERROR] $0 - Message: $1 ${reset} \n"
  exit
}