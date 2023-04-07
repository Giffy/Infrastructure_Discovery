#!/bin/bash
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

IP_PREFIX="192.168.43."
PORT_RANGE="80 443 8080 8443"

# Loop over each port in the range
for PORT in ${PORT_RANGE}; do
  # Loop over each IP address in the range
  for IP in $(seq -f ${IP_PREFIX}"%g" 207 208); do
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

