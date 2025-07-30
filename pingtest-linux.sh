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
    if command -v curl >/dev/null 2>&1; then
        public_ip=$(curl -s --connect-timeout 10 ifconfig.me || echo "Unable to retrieve")
    elif command -v wget >/dev/null 2>&1; then
        public_ip=$(wget -qO- --timeout=10 ifconfig.me || echo "Unable to retrieve")
    else
        public_ip="curl/wget not available"
    fi

    # Get local IP address - try multiple methods
    if command -v ip >/dev/null 2>&1; then
        local_ip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K\S+' || echo "Not connected")
        if [ "$local_ip" = "Not connected" ]; then
            local_ip=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d'/' -f1 || echo "Not connected")
        fi
    elif command -v hostname >/dev/null 2>&1; then
        local_ip=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "Not connected")
    else
        local_ip="Not connected"
    fi

    # Get subnet mask and router
    if [ "$local_ip" != "Not connected" ] && command -v ip >/dev/null 2>&1; then
        subnet=$(ip route | grep "$local_ip" | head -1 | awk '{print $1}' || echo "Not available")
        router=$(ip route | grep default | head -1 | awk '{print $3}' || echo "Not available")
    else
        subnet="Not connected"
        router="Not connected"
    fi

    # Get DNS servers
    if [ -f /etc/resolv.conf ]; then
        dns_servers=$(grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | paste -sd, - || echo "Not available")
    else
        dns_servers="Not available"
    fi

    # Get hostname
    hostname=$(hostname 2>/dev/null || echo "Not available")

    # Get network connection type and name
    connection_type="Unknown"
    network_name="N/A"
    
    # Check for wireless interfaces
    if [ -d /proc/net/wireless ] && [ -s /proc/net/wireless ]; then
        wifi_interface=$(tail -n +3 /proc/net/wireless | head -1 | cut -d: -f1 | tr -d ' ')
        if [ -n "$wifi_interface" ] && command -v iwgetid >/dev/null 2>&1; then
            network_name=$(iwgetid -r 2>/dev/null || echo "N/A")
            connection_type="Wi-Fi"
        elif [ -n "$wifi_interface" ]; then
            connection_type="Wi-Fi"
        fi
    fi
    
    # If not Wi-Fi, check for active ethernet
    if [ "$connection_type" = "Unknown" ] && command -v ip >/dev/null 2>&1; then
        ethernet_interface=$(ip link show | grep -E "^[0-9]+: (eth|enp|ens)" | grep "state UP" | head -1 | cut -d: -f2 | tr -d ' ')
        if [ -n "$ethernet_interface" ]; then
            connection_type="Ethernet"
        fi
    fi

    # Get OS information
    os_name="Unknown"
    os_version="Unknown"
    
    if command -v lsb_release >/dev/null 2>&1; then
        os_name=$(lsb_release -si 2>/dev/null || echo "Unknown")
        os_version=$(lsb_release -sr 2>/dev/null || echo "Unknown")
    elif [ -f /etc/os-release ]; then
        os_name=$(grep '^NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"' || echo "Unknown")
        os_version=$(grep '^VERSION=' /etc/os-release | cut -d'=' -f2 | tr -d '"' || echo "Unknown")
    elif [ -f /etc/redhat-release ]; then
        os_info=$(cat /etc/redhat-release)
        os_name=$(echo "$os_info" | awk '{print $1}')
        os_version=$(echo "$os_info" | awk '{print $3}')
    elif command -v uname >/dev/null 2>&1; then
        os_name=$(uname -s)
        os_version=$(uname -r)
    fi

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
    ping_result=$(ping -c "$ping_count" "$site" 2>&1)
    echo "$ping_result" | tee -a "$default_filename"
    echo "" | tee -a "$default_filename"
done

echo "Results saved to $default_filename"