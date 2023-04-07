
# Importing modules
source ../modules/error_management.sh
source ../modules/read_setup.sh

# Read setup files
#read_setup_ini_file

echo "version: "$(get_setting_value "Version" "version_num" )

# curl -I -silent http://www.google.com | grep Server


#install.sh

