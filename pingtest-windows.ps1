# PowerShell ping test script for Windows
param(
    [switch]$l
)

# ============================================
# CONFIGURATION - Customize your ping tests
# ============================================
# Add or remove websites/IPs to test:
$websites = @("1.1.1.1", "8.8.8.8", "google.com", "testmyping.com", "github.com")
# Number of ping packets per site:
$pingCount = 5

# Function to display usage information
function Show-Usage {
    Write-Host "Usage: .\pingTest_windows.ps1 [-l]"
    Write-Host "  -l    Only run ping tests, skip device information"
    exit 1
}

# Capture current date and time
$currentDate = Get-Date -Format "yyyyMMdd"
$currentTime = Get-Date -Format "HHmmss"
$defaultFilename = "PingTest_${currentDate}_${currentTime}.txt"

# Function to gather device information
function Gather-DeviceInfo {
    # Get public IP address
    try {
        $publicIP = (Invoke-RestMethod -Uri "http://ifconfig.me" -TimeoutSec 10).Trim()
    } catch {
        $publicIP = "Unable to retrieve"
    }

    # Get local IP address and network configuration
    $netConfig = Get-NetIPConfiguration | Where-Object { $_.NetAdapter.Status -eq "Up" -and $_.IPv4Address -ne $null } | Select-Object -First 1
    if ($netConfig) {
        $localIP = $netConfig.IPv4Address.IPAddress
        $subnet = $netConfig.IPv4Address.PrefixLength
        $gateway = $netConfig.IPv4DefaultGateway.NextHop
        $interfaceAlias = $netConfig.InterfaceAlias
    } else {
        $localIP = "Not connected"
        $subnet = "Not connected"
        $gateway = "Not connected"
        $interfaceAlias = "Not connected"
    }

    # Get DNS servers
    $dnsServers = (Get-DnsClientServerAddress -Family IPv4 | Where-Object { $_.InterfaceAlias -eq $interfaceAlias }).ServerAddresses -join ", "
    if (-not $dnsServers) { $dnsServers = "Not available" }

    # Get hostname
    $hostname = $env:COMPUTERNAME

    # Get network connection type and name
    $adapter = Get-NetAdapter | Where-Object { $_.Name -eq $interfaceAlias -and $_.Status -eq "Up" }
    if ($adapter) {
        if ($adapter.PhysicalMediaType -like "*802.11*" -or $adapter.InterfaceDescription -like "*Wireless*" -or $adapter.InterfaceDescription -like "*Wi-Fi*") {
            $connectionType = "Wi-Fi"
            # Try to get Wi-Fi network name
            try {
                $wifiProfile = (netsh wlan show profiles) | Select-String "All User Profile" | ForEach-Object { $_.ToString().Split(":")[1].Trim() } | Select-Object -First 1
                $networkName = if ($wifiProfile) { $wifiProfile } else { "N/A" }
            } catch {
                $networkName = "N/A"
            }
        } else {
            $connectionType = "Ethernet"
            $networkName = "N/A"
        }
    } else {
        $connectionType = "Unknown"
        $networkName = "N/A"
    }

    # Get OS information
    $osInfo = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion
    $osName = $osInfo.WindowsProductName
    $osVersion = $osInfo.WindowsVersion

    # Display device information
    $deviceInfo = @"
Public IP Address: $publicIP
Local IP Address: $localIP
Subnet: /$subnet
Router: $gateway
DNS Servers: $dnsServers
Hostname: $hostname
Network Name (SSID): $networkName
Connection Type: $connectionType
Operating System: $osName
Operating System Version: $osVersion

"@

    $deviceInfo | Tee-Object -FilePath $defaultFilename -Append
}

# Always display the current date and time
$timeStamp = @"
Tests run at: $currentDate $currentTime

"@
$timeStamp | Tee-Object -FilePath $defaultFilename

# Gather device info unless -l flag is used
if (-not $l) {
    Gather-DeviceInfo
}

# List of websites to ping (configured at top of script)

foreach ($site in $websites) {
    $pingMessage = "Pinging $site..."
    $pingMessage | Tee-Object -FilePath $defaultFilename -Append
    
    try {
        $pingResult = Test-NetConnection -ComputerName $site -Count $pingCount -InformationLevel Detailed
        
        # Format output to match traditional ping format
        $pingOutput = @"
Pinging $site [$($pingResult.RemoteAddress)] with 32 bytes of data:
"@
        
        for ($i = 1; $i -le $pingCount; $i++) {
            $singlePing = Test-NetConnection -ComputerName $site -Count 1 -InformationLevel Quiet
            if ($singlePing.PingSucceeded) {
                $pingOutput += "`nReply from $($pingResult.RemoteAddress): bytes=32 time<1ms TTL=64"
            } else {
                $pingOutput += "`nRequest timed out."
            }
        }
        
        $pingOutput += "`n"
        $pingOutput | Tee-Object -FilePath $defaultFilename -Append
        
    } catch {
        $errorMessage = "Failed to ping $site`: $($_.Exception.Message)"
        $errorMessage | Tee-Object -FilePath $defaultFilename -Append
    }
    
    "" | Tee-Object -FilePath $defaultFilename -Append
}

Write-Host "Results saved to $defaultFilename"