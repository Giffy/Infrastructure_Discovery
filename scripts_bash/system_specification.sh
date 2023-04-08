#!/bin/bash
################################################################
# Summary of host specification



# Importing modules
source ../modules/error_management.sh
source ../modules/read_setup.sh
source ../modules/validators.sh


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
cpu_arch=$(uname -m)
cpu_model=$(grep "model name" /proc/cpuinfo | awk -F ":" '{print $2}' | sed 's/^ //g' | uniq)
cpu_cores=$(get_cpu_cores)
max_speed=$(grep "cpu MHz" /proc/cpuinfo | awk -F ":" '{print $2}' | sed 's/^ //g' | uniq | sort -nr | head -n 1)
min_speed=$(grep "cpu MHz" /proc/cpuinfo | awk -F ":" '{print $2}' | sed 's/^ //g' | uniq | sort -n | head -n 1)

echo "Architecture: $cpu_arch, CPU: $cpu_model, $cpu_cores cores, min speed $min_speed Mhz, max speed $max_speed Mhz"

# Get the memory information
mem_total=$(free | awk 'NR==2 {print $2}')
mem_used=$(free | awk 'NR==2 {print $3}')
mem_free=$(($mem_total-$mem_used))

echo "Memory: $mem_total kB total, $mem_used kB used, $mem_free kB free"

## Get the disk information
disk_total=$(df / | awk '{print $2}' | sed 1d | awk '{print $1/1024000}' )
disk_free=$(df / | awk '{print $4}' | sed 1d | awk '{print $1/1024000}')
disk_used=$(df / | awk '{print $3}' | sed 1d | awk '{print $1/1024000}')


echo "Disk / : $disk_total GB total, $disk_used GB used, $disk_free GB free"

## Get operating system information
os_type=$(uname -s | tr '[:upper:]' '[:lower:]')
os_name=$(lsb_release -ds)

os_kernel=$(uname -r)

os_distribution=$(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)
os_version=$(cat /etc/os-release | grep VERSION_ID | cut -d'"' -f2)
codename=$(lsb_release -c | awk -F "\t" '{print $2}' )


echo "Type: $os_type, OS: $os_name, kernel $os_kernel"
echo "Distribution: $os_distribution, Version: $os_version, codename: $codename"



## Get network information
hostname=$(hostname)
## Get the network interface name
interface=$(ip route | awk '/default/ {print $5}')
## Get the IP address of the network interface
ip_address=$(ip addr show dev $interface | awk '/inet / {print $2}')

default_route=$(ip route | awk '/default/ {print $3}')



echo "Hostname: $hostname"
echo "Network interface: $interface, IP address: $ip_address, Default route: $default_route"




