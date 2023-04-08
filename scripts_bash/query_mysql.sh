#!/bin/bash
# Importing modules
source ../modules/error_management.sh
source ../modules/read_setup.sh
source ../modules/validators.sh


# MySQL host, credentials and schema
DB_HOST=$(get_setting_value "mysql" "host" )
DB_USER=$(get_setting_value "mysql" "user" )
DB_PASSWORD=$(get_setting_value "mysql" "password" )
DB_NAME=$(get_setting_value "mysql" "schema" )

# Set query
QUERY="SELECT * FROM mytable"

# Run the query and save the results to a file
mysql --host=$DB_HOST --user=$DB_USER --password=$DB_PASSWORD --database=$DB_NAME --execute="$QUERY" > results.txt

# Display the results
cat results.txt