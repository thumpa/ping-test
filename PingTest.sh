#!/bin/bash

websites=("1.1.1.1" "8.8.8.8" "google.com" "testmyping.com" "github.com")  # Add your desired websites here
ping_count=10 # Set number of pins per site

current_date=$(date +'%Y%m%d')
current_time=$(date +'%H%M%S')
default_filename="PingTest_${current_date}_${current_time}.txt"

echo "Results will be saved to $default_filename"
echo -e "Ping Test Results\n" > "$default_filename"

for site in "${websites[@]}"; do
    echo "Pinging $site..."
    ping_result=$(ping -c "$ping_count" "$site")
    echo -e "Pinging $site...\n$ping_result\n\n" >> "$default_filename"
    echo -e "\n$ping_result\n"
done

echo "Results saved to $default_filename"
