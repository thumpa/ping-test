# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a cross-platform ping testing utility that performs network connectivity tests to predefined sites and generates timestamped results. The project includes platform-specific scripts for maximum compatibility and accuracy:

**Platform-Specific Scripts:**

- `pingtest-macos.sh` - macOS version with device info gathering and `-l` flag for lite mode
- `pingtest-windows.ps1` - PowerShell version for Windows
- `pingtest-linux.sh` - Bash version for Linux

## Commands

### Running Tests

**macOS:**

```bash
# Full ping test with device information
sh pingtest-macos.sh

# Ping tests only (no device info)
sh pingtest-macos.sh -l
```

**Windows (PowerShell):**

```powershell
# Full ping test with device information
.\pingtest-windows.ps1

# Ping tests only (no device info)
.\pingtest-windows.ps1 -l
```

**Linux:**

```bash
# Full ping test with device information
./pingtest-linux.sh

# Ping tests only (no device info)
./pingtest-linux.sh -l
```

### Making Scripts Executable

**macOS/Linux:**

```bash
chmod +x pingtest-macos.sh pingtest-linux.sh
```

**Windows:**
PowerShell scripts (.ps1) may require execution policy changes:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Architecture

### Core Components

**Main Script (`pingtest-macos.sh`)**:

- Supports command-line flag `-l` for lite mode
- `gather_device_info()` function collects comprehensive network and system information
- Configurable website list and ping count via variables
- Uses `tee` for simultaneous terminal output and file logging

**Configuration Variables** (located at top of each script for easy editing):

- `websites` array: List of sites to ping (default: 1.1.1.1, 8.8.8.8, google.com, testmyping.com, github.com)
- `ping_count`: Number of pings per site (5 for all scripts)

**Important**: Configuration variables are positioned at the top of each script (after shebang/param blocks) with clear section headers for immediate user visibility and easy customization.

**Output Format**:

- Timestamped filename: `PingTest_YYYYMMDD_HHMMSS.txt`
- Combines device information and ping results in structured format
- Results saved to file and displayed in terminal simultaneously

### Platform Dependencies

Each platform uses native commands for maximum accuracy:

**macOS (`pingtest-macos.sh`):**

- `ipconfig getifaddr` for local IP
- `scutil --dns` for DNS servers  
- `networksetup` for network interface details
- `sw_vers` for OS information

**Windows (`pingtest-windows.ps1`):**

- `Test-NetConnection` for ping tests
- `Get-NetIPConfiguration` for network details
- `Get-DnsClientServerAddress` for DNS servers
- `Get-ComputerInfo` for system information
- `Invoke-RestMethod` for public IP

**Linux (`pingtest-linux.sh`):**

- `ping` command (standard across distributions)
- `ip` command for network configuration
- `/etc/resolv.conf` for DNS servers
- `lsb_release` or `/etc/os-release` for OS info
- `iwgetid` for Wi-Fi network names

### Device Information Collection

All platforms collect the same information with consistent output formatting:

- Public IP (via ifconfig.me)
- Local IP, subnet, router
- DNS servers
- Hostname and network name/SSID
- Connection type (Wi-Fi/Ethernet)
- OS name and version

**Cross-Platform Compatibility:**

- All scripts use the same website list and ping count (5 per site)
- Identical output file naming: `PingTest_YYYYMMDD_HHMMSS.txt`
- Consistent field ordering in device information section
- Same `-l` flag functionality for lite mode (ping tests only)
