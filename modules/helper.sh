  # Function to count the number of elements in a list
  function list_length () {
      echo $(wc -w <<< "$@")
  }


  # Function to print a progress bar
  function progress_bar() {
      local total_iterations=$1
      local current_mark=$2

      # calculate the percentage of completion
      percentage=$(($current_mark * 100 / $total_iterations))

      # output the progress bar
      printf "[%-50s] %d%%\r" $(printf "#%.0s" $(seq 1 $((percentage/2)) )) $percentage
  }