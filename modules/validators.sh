  # Function to validate IP address
  function check_ip() {
    # Regular expression to match an IP address
    ip_regex="^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
    # Check if the input matches the IP address pattern
    if ! [[ $1 =~ $ip_regex ]]; then
      print_error "$1 is not a valid IP address"
    fi
  }

  # Function to validate port number
  function check_port() {
    # Regular expression to match a valid port number
    port_regex="^[0-9]{1,5}$"
    # Check if the input matches the port number pattern
    if [[ $1 =~ $port_regex ]] && [ $1 -ge 1 -a $1 -le 65535 ]; then
      return
    else
      print_error "$1 is not a valid port number"
    fi
  }


  list_length () {
          echo $(wc -w <<< "$@")
  }