#!/bin/bash
# This script uses curl to get the server type running in a IP
# possible arguments IP address, list of IP addresses, port, list of ports
# Usage: find_webserver <list of IP addresses> <list of ports>
# Example: find_webserver "192.168.1.1 192.168.1.3" "80 443"
# Example for ip_prefix : find_webserver "192.168.1" "80 443"


# Importing modules
source ../modules/error_management.sh
source ../modules/read_setup.sh
source ../modules/validators.sh
source ../modules/helper.sh

# Read setup files
OUTPUT_FORMAT=$(get_setting_value "Output" "format" )

# Arguments
  # Define function to display help message
  function display_help {
    echo "Usage: $0 <host_list> <port_list> [options]"
    echo "Example: find_webServer_curl.sh -s \"192.168.1.2 192.168.1.20\" -p \"80 443\""
    echo "Example: find_webServer_curl.sh -i \"192.168.1\" -p \"80 443\""
    echo ""
    echo "Options:"
    echo "-s, --servers=LIST  List of hosts to scan"
    echo "-p, --ports=LIST  List of ports to scan"
    echo "-i, --ippreffix=LIST  List of IP prefix 192.168.1"
    echo "-r, --range: Range of hosts (4th IP digit) TODO"
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
      -p|--ports)
        PORT_LIST="$2"
        shift
        ;;
      -i|--ippreffix)
        IP_PREFIX="$2"
        ARGUMENTS=1
        shift
        ;;
      -r|--rangehost)
        HOST_RANGE="$2"
        shift
        ;;
      -t|--rangeports)
        PORT_RANGE="$2"
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
      echo "Web server is running on ${IP}:${PORT} ${result}"
      ;;
    csv)
      csv_delimiter=$(get_setting_value "Output" "csv_delimiter" )
      echo "${IP}${csv_delimiter}${PORT}${csv_delimiter}${server}${csv_delimiter}${version}"
      ;;
    influx)
      timestamp=$(date +"%s")
      influx_measurement=$(get_setting_value "Output" "influx_measurement" )
      echo "${influx_measurement} ip=${IP},port=${PORT} server='${server}',version='${version}' ${timestamp}0000 "
      ;;
    *)
      echo ${result}
      ;;
  esac
}


# Main script

i=1
# Loop over each port in the range
for PORT in ${PORT_LIST}; do
  # validate port number
  check_port "$PORT"
  if [ ${#IP_PREFIX} -gt 0 ]; then
    total_hosts=$(( $(list_length $IP_PREFIX) * 254))
    total_iterations=$(($total_hosts*$(list_length $PORT_LIST)))
    # Loop over each IP_PREFIX in the range
    for IP in $(seq -f ${IP_PREFIX}".%g" 1 254); do
      # validate ip
      check_ip "${IP}"
      # Progress bar
      progress_bar ${total_iterations} ${i}
      i=$((${i}+1))
      # Make a curl request to Web servers
      result=$(curl --max-time 3 --silent --head http://${IP}:${PORT} | grep "Server" | tr -d '\r' )
      # Check if curl succeeded and Web Server was found
      if [ ${#result} -gt 0 ]; then
        server=$(echo ${result} | awk '{print $2 }' | cut -d '/' -f 1)
        version=$(echo ${result} | awk '{print $2 }' | cut -d '/' -f 2)
        build_output
      fi
    done
  else
    total_iterations=$(($(list_length $HOST_LIST)*$(list_length $PORT_LIST)))
    # Loop over each IP address in the range
    for IP in ${HOST_LIST}; do
      # validate ip
      check_ip "${IP}"
      # Progress bar
      progress_bar ${total_iterations} ${i}
      i=$((${i}+1))
      # Make a curl request to Web servers
      result=$(curl --max-time 3 --silent --head http://${IP}:${PORT} | grep "Server" | tr -d '\r')
      # Check if curl succeeded and Web Server was found
      if [ ${#result} -gt 0 ]; then
        server=$(echo ${result} | awk '{print $2 }' | cut -d '/' -f 1)
        version=$(echo ${result} | awk '{print $2 }' | cut -d '/' -f 2)
        build_output
      fi
    done
  fi
done

