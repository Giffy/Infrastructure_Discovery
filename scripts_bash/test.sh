#!/bin/bash

# define a function with four arguments, two of which are optional
function my_function() {
    local arg1=""
    local arg2=""
    local arg3=""
    local arg4=""

    # loop over the arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a|--arg1)
                arg1="$2"
                shift 2
                ;;
            -b|--arg2)
                arg2="$2"
                shift 2
                ;;
            -c|--arg3)
                arg3="$2"
                shift 2
                ;;
            --arg4)
                arg4="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # output the arguments
    echo "arg1: $arg1"
    echo "arg2: $arg2"
    echo "arg3: $arg3"
    echo "arg4: $arg4"
}

# call the function with some arguments
my_function -c "value3" -a "value1" --arg4 "value4"
