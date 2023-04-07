#!/bin/bash
# This script uses curl to get the server type running in a IP
# TODO add arguments
# possible arguments IP address, list of IP addresses, port, list of ports
# Usage: find_webserver <list of IP addresses> <list of ports>
# Example: find_webserver "192.168.1.1 192.168.1.3" "80 443"
# Example for range : find_webserver -r 1-254 "192.168.1" "80 443"


# Importing modules
source ../modules/error_management.sh
source ../modules/read_setup.sh

# Read setup files
OUTPUT_FORMAT=$(get_setting_value "Output" "format" )

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

IP_PREFIX="192.168.1."
PORT_RANGE="80 443 8080 8443"

# Loop over each port in the range
for PORT in ${PORT_RANGE}; do
  # Loop over each IP address in the range
  for IP in $(seq -f ${IP_PREFIX}"%g" 1 254); do
    # Make a curl request to Web servers
    result=$(curl --max-time 3 --silent --head http://${IP}:${PORT} | grep "Server" | tr -d '\r')
    # Check if curl succeeded and Web Server was found
    if [ ${#result} -gt 0 ]; then
      server=$(echo ${result} | awk '{print $2 }' | cut -d '/' -f 1)
      version=$(echo ${result} | awk '{print $2 }' | cut -d '/' -f 2)
      build_output
    fi
  done
done

