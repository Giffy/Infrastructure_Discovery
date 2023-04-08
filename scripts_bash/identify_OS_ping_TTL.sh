#!/bin/bash
# Importing modules
source ../modules/error_management.sh
source ../modules/read_setup.sh
source ../modules/validators.sh

# Read setup files
OUTPUT_FORMAT=$(get_setting_value "Output" "format" )

# Arguments
  # Define function to display help message
  function display_help {
    echo "Usage: $0 <host_list> <port_list> [options]"
    echo "Example: identify_OS_ping_TTL.sh -s \"192.168.1.2 192.168.1.20\" "
    echo ""
    echo "Options:"
    echo "-s, --servers=LIST  List of hosts to scan"
    echo "-h, --help: Display this help message"
  }

  # Parse command line arguments
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      -h|--help)
        display_help
        exit 0
        ;;
      -s|--servers)
        HOST_LIST="$2"
        ARGUMENTS=1
        shift
        ;;
    esac
    shift
  done

  # Check if file option is provided
  if [ -z "$ARGUMENTS" ]; then
    echo "No arguments provided"
    echo ""
    display_help
    exit 1
  fi


# Build output
function build_output(){
  case $OUTPUT_FORMAT in
    console)
      echo "Operating system ${IP} ${result}"
      ;;
    csv)
      csv_delimiter=$(get_setting_value "Output" "csv_delimiter" )
      echo "${IP}${csv_delimiter}${result}"
      ;;
    influx)
      timestamp=$(date +"%s")
      influx_measurement=$(get_setting_value "Output" "influx_measurement" )
      echo "${influx_measurement} ip=${IP} OS='${result}' ${timestamp}0000 "
      ;;
    *)
      echo ${result}
      ;;
  esac
}



for IP in ${HOST_LIST}; do
  # validate ip
  check_ip "${IP}"
  # Extract the TTL value from the ping response
  ttl=$(ping -c 1 $IP | awk '/ttl/{print $6}' | awk -F= '{print $2}')

  if [[ -z $ttl ]]; then
    print_error "Unable to determine TTL value"
  fi

  if [[ ${ttl} -eq 64 ]]; then
    result="Linux"
  elif [[ ${ttl} -eq 128 ]]; then
    result="Windows"
  elif [[ ${ttl} -eq 254 ]]; then
    result="Solaris"
  else
    result="Unknown operating system"
  fi
  build_output
done