#!/bin/bash
################################################################
# Summary of host specification



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
    echo "Example: find_webServer_curl.sh -s \"192.168.1.2 192.168.1.20\" -p \"80 443\""
    echo "Example: find_webServer_curl.sh -i \"192.168.1\" -p \"80 443\""
    echo ""
    echo "Options:"
    echo "-c, --cpu     CPU specification"
    echo "-m, --memory  Memory specification"
    echo "-d, --disk    Root disk specification"
    echo "-o, --os      OS distribution"
    echo "-n, --network Network specification"
    echo "-h, --help    Display this help message"
  }

  num_variables=$#
  # Parse command line arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)    display_help; exit 0  ;;
      -c|--cpu)     CPU=1       ;;
      -m|--memory)  MEMORY=1    ;;
      -d|--disk)    DISK=1      ;;
      -o|--os)      OS=1        ;;
      -n|--network) NETWORK=1   ;;
    esac
    shift
  done

  if [[ $num_variables -eq 0 ]]; then
    CPU=1; MEMORY=1; DISK=1; OS=1; NETWORK=1
  fi

# Build output
function console_output(){
  if [[ ${CPU} ]];then
    echo "Architecture: $cpu_arch, CPU: $cpu_model, cores: $cpu_cores , min speed: $min_speed Mhz, max speed: $max_speed Mhz"
  fi

  if [[ ${MEMORY} ]];then
    echo "Total memory: $mem_total kB, Used memory: $mem_used kB, Free memory: $mem_free kB"
  fi

  if [[ ${DISK} ]];then
    echo "Disk / : $disk_total GB total, $disk_used GB used, $disk_free GB free"
  fi

  if [[ ${OS} ]];then
    echo "Type: $os_type, OS: $os_name, kernel $os_kernel"
    echo "Distribution: $os_distribution, Version: $os_version, codename: $codename"
  fi

  if [[ ${NETWORK} ]];then
    echo "Hostname: $hostname"
    echo "Network interface: $interface, IP address: $ip_address, Default route: $default_route"
  fi
}

function csv_output(){
  csv_delimiter=$(get_setting_value "Output" "csv_delimiter" )
  if [[ ${CPU} ]];then
    echo "Architecture${csv_delimiter}CPU${csv_delimiter}cores${csv_delimiter}min_speed${csv_delimiter}max_speed"
    echo "$cpu_arch${csv_delimiter}$cpu_model${csv_delimiter}$cpu_cores${csv_delimiter}$min_speed${csv_delimiter}$max_speed"
  fi
  if [[ ${MEMORY} ]];then
    echo "Total_memory${csv_delimiter}Used_memory${csv_delimiter}Free_memory"
    echo "$mem_total${csv_delimiter}$mem_used${csv_delimiter}$mem_free"
  fi
  if [[ ${DISK} ]];then
    echo "Disk${csv_delimiter}total${csv_delimiter}used${csv_delimiter}free"
    echo "/${csv_delimiter}$disk_total${csv_delimiter}$disk_used${csv_delimiter}$disk_free"
  fi
  if [[ ${OS} ]];then
    echo "Type${csv_delimiter}OS${csv_delimiter}kernel${csv_delimiter}Distribution${csv_delimiter}Version${csv_delimiter}codename"
    echo "$os_type${csv_delimiter}$os_name${csv_delimiter}$os_kernel${csv_delimiter}$os_distribution${csv_delimiter}$os_version${csv_delimiter}$codename"
  fi
  if [[ ${NETWORK} ]];then
    echo "Hostname${csv_delimiter}Network_interface${csv_delimiter}IP_address${csv_delimiter}Default route"
    echo "$hostname${csv_delimiter}$interface${csv_delimiter}$ip_address${csv_delimiter}$default_route"
  fi
}

function influx_output(){
  timestamp=$(date +"%s")
  influx_measurement=$(get_setting_value "Output" "influx_measurement" )

  if [[ ${CPU} ]];then
    echo "${influx_measurement} host=${hostname} architecture=${cpu_arch},CPU='${cpu_model}',cores=${cpu_cores}i,min_speed=${min_speed},max_speed=${max_speed} ${timestamp}0000 "
  fi
  if [[ ${MEMORY} ]];then
    echo "${influx_measurement} host=${hostname} Total_memory=${mem_total},Used_memory=${mem_used},Free_memory=${mem_free} ${timestamp}0000 "
  fi
  if [[ ${DISK} ]];then
    echo "${influx_measurement} host=${hostname},Disk=/ total='${disk_total}',used='${disk_used}',free='${disk_free}' ${timestamp}0000 "
  fi
  if [[ ${OS} ]];then
    echo "${influx_measurement} host=${hostname} Type=${os_type},OS='${os_name}',kernel='${os_kernel}',Distribution='${os_distribution}',Version='${os_version}',codename='${codename}' ${timestamp}0000 "
  fi
  if [[ ${NETWORK} ]];then
    echo "${influx_measurement} host=${hostname},Network_interface=${interface} IP_address='${ip_address}',Default_route='${default_route}' ${timestamp}0000 "
  fi
}

function build_output(){
  case $OUTPUT_FORMAT in
    console) console_output;;
    csv)     csv_output;;
    influx)  influx_output;;
    *)       echo ${result};;
  esac
}


get_cpu_cores(){
    local cpu_count
    if type -P nproc &>/dev/null; then
        nproc
        return
    elif is_mac; then
        cpu_count="$(sysctl -n hw.ncpu)"
    else
        cpu_count="$(grep -c '^processor[[:space:]]*:' /proc/cpuinfo)"
    fi
    echo "$cpu_count"
}



# Get the CPU information
if [[ ${CPU} ]];then
  cpu_arch=$(uname -m)
  cpu_model=$(grep "model name" /proc/cpuinfo | awk -F ":" '{print $2}' | sed 's/^ //g' | uniq)
  cpu_cores=$(get_cpu_cores)
  max_speed=$(grep "cpu MHz" /proc/cpuinfo | awk -F ":" '{print $2}' | sed 's/^ //g' | uniq | sort -nr | head -n 1)
  min_speed=$(grep "cpu MHz" /proc/cpuinfo | awk -F ":" '{print $2}' | sed 's/^ //g' | uniq | sort -n | head -n 1)
fi

# Get the memory information
if [[ ${MEMORY} ]];then
  mem_total=$(free | awk 'NR==2 {print $2}')
  mem_used=$(free | awk 'NR==2 {print $3}')
  mem_free=$(($mem_total-$mem_used))
fi

## Get the disk information
if [[ ${DISK} ]];then
  disk_total=$(df / | awk '{print $2}' | sed 1d | awk '{print $1/1024000}' )
  disk_free=$(df / | awk '{print $4}' | sed 1d | awk '{print $1/1024000}')
  disk_used=$(df / | awk '{print $3}' | sed 1d | awk '{print $1/1024000}')
fi

## Get operating system information
if [[ ${OS} ]];then
  os_type=$(uname -s | tr '[:upper:]' '[:lower:]')
  os_name=$(lsb_release -ds)
  os_kernel=$(uname -r)
  os_distribution=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
  os_version=$(cat /etc/os-release | grep VERSION_ID | cut -d'"' -f2)
  codename=$(lsb_release -c | awk -F "\t" '{print $2}' )
fi

## Get network information
if [[ ${NETWORK} ]];then
  ## Get the network interface name
  interface=$(ip route | awk '/default/ {print $5}')
  ## Get the IP address of the network interface
  ip_address=$(ip addr show dev "${interface}" | awk '/inet / {print $2}' | cut -d'/' -f1)

  default_route=$(ip route | awk '/default/ {print $3}')
fi

hostname=$(hostname)
build_output

