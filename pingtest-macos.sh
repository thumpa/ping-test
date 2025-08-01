#!/bin/bash

# ============================================
# CONFIGURATION - Customize your ping tests
# ============================================
# Add or remove websites/IPs to test:
websites=("1.1.1.1" "8.8.8.8" "google.com" "testmyping.com" "github.com")
# Number of ping packets per site:
ping_count=5

# Function to display usage information
usage() {
    echo "Usage: $0 [-l]"
    echo "  -l    Only run ping tests, skip device information"
    exit 1
}

# Parse options
while getopts ":l" opt; do
    case ${opt} in
        l )
            skip_info=true
            ;;
        \? )
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Capture current date and time
current_date=$(date +'%Y%m%d')
current_time=$(date +'%H%M%S')
default_filename="PingTest_${current_date}_${current_time}.txt"

# Function to gather device information
gather_device_info() {
    # Get public IP address
    public_ip=$(curl -s ifconfig.me)

    # Get local IP address
    local_ip=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "Not connected")

    # Get subnet mask and router for active interfaces
    if [ "$local_ip" != "Not connected" ]; then
        active_interface=$(route get default | grep interface | awk '{print $2}')
        subnet=$(ipconfig getoption "$active_interface" subnet_mask)
        router=$(ipconfig getoption "$active_interface" router)
    else
        subnet="Not connected"
        router="Not connected"
    fi

    # Get DNS servers
    dns_servers=$(scutil --dns | grep 'nameserver\[[0-9]*\]' | awk '{print $3}' | sort -u | paste -s -d, -)

    # Get hostname
    hostname=$(hostname)

    # Get network name (SSID) and connection type (Wi-Fi or Ethernet)
    network_services=$(networksetup -listallhardwareports)
    wifi_interface=$(echo "$network_services" | awk '/Wi-Fi|AirPort/{getline; print $2}')
    ethernet_interface=$(echo "$network_services" | awk '/Ethernet/{getline; print $2}')

    if [ -n "$wifi_interface" ] && ifconfig "$wifi_interface" | grep -q "status: active"; then
        connection_type="Wi-Fi"
        network_name=$(networksetup -getairportnetwork "$wifi_interface" | cut -d ":" -f2 | sed 's/^ *//')
    elif [ -n "$ethernet_interface" ] && ifconfig "$ethernet_interface" | grep -q "status: active"; then
        connection_type="Ethernet"
        network_name="N/A"
    else
        connection_type="Unknown"
        network_name="N/A"
    fi

    # Get other accessible info: OS name and version
    os_name=$(sw_vers -productName)
    os_version=$(sw_vers -productVersion)

    # Display device information
    {
        echo "Public IP Address: $public_ip"
        echo "Local IP Address: $local_ip"
        echo "Subnet: $subnet"
        echo "Router: $router"
        echo "DNS Servers: $dns_servers"
        echo "Hostname: $hostname"
        echo "Network Name (SSID): $network_name"
        echo "Connection Type: $connection_type"
        echo "Operating System: $os_name"
        echo "Operating System Version: $os_version"
        echo ""
    } | tee -a "$default_filename"
}

# Always display the current date and time
{
    echo "Tests run at: $current_date $current_time"
    echo ""
} | tee -a "$default_filename"

# Gather device info unless -l flag is used
if [ -z "$skip_info" ]; then
    gather_device_info
fi

# List of websites to ping (configured at top of script)

for site in "${websites[@]}"; do
    echo "Pinging $site..." | tee -a "$default_filename"
    ping_result=$(ping -c "$ping_count" "$site")
    echo "$ping_result" | tee -a "$default_filename"
    echo "" | tee -a "$default_filename"
done

echo "Results saved to $default_filename"