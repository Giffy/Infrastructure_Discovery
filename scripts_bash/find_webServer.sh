#!/bin/bash
# Importing modules
source ../modules/error_management.sh
source ../modules/read_setup.sh

# Read setup files
#echo "version: "$(get_setting_value "Version" "version_num" )

IP_PREFIX="192.168.1."
PORT_RANGE="80 443 8080 8443"

# Loop over each port in the range
for PORT in ${PORT_RANGE}; do
  # Loop over each IP address in the range
  for IP in $(seq -f ${IP_PREFIX}"%g" 1 254); do
    # Make a curl request to Web servers
    result=$(curl --max-time 3 --silent --head http://${IP}:${PORT} | grep "Server")
    # Check if curl succeeded and Web Server was found
    if [ $? -eq 0 ]; then
      echo "Web server is running on ${IP}:${PORT} ${result}"
    fi
  done
done

