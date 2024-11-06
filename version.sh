#!/bin/bash

# Path to the file containing IP addresses
ip_list="mysql.txt"

# Function to scan a batch of IP addresses
scan_batch() {
    # Read the batch of 100 IP addresses from the input
    for ip in "$@"
    do
        sudo nmap -p 3306 -sV -O "$ip" &
    done
    # Wait for all background processes to complete before moving on to the next batch
    wait
}

# Read the file and process IPs in batches of 100
batch_size=100
ip_batch=()

count=0
while IFS= read -r ip
do
    ip_batch+=("$ip")
    count=$((count + 1))

    # If batch size reaches 100, run the batch and reset
    if [ "$count" -ge "$batch_size" ]; then
        scan_batch "${ip_batch[@]}"
        ip_batch=()  # Reset the batch
        count=0
    fi
done < "$ip_list"

# If there are any leftover IPs less than a full batch, scan them
if [ "${#ip_batch[@]}" -gt 0 ]; then
    scan_batch "${ip_batch[@]}"
fi
