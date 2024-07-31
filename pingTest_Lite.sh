#!/bin/bash

websites=("1.1.1.1" "8.8.8.8" "google.com" "testmyping.com" "github.com")  # Add your desired websites here
ping_count=10 # Set number of pins per site

current_date=$(date +'%Y%m%d')
current_time=$(date +'%H%M%S')
default_filename="PingTest_${current_date}_${current_time}.txt"

echo "Results will be saved to $default_filename"
echo "Ping Test Results" > "$default_filename"
echo "" >> "$default_filename"

for site in "${websites[@]}"; do
    echo "Pinging $site..."
    ping_result=$(ping -c "$ping_count" "$site")
    echo "Pinging $site..." >> "$default_filename"
    echo "$ping_result" >> "$default_filename"
    echo "" >> "$default_filename"
    echo "Pinging $site..."
    echo "$ping_result"
    echo ""
done

echo "Results saved to $default_filename"
