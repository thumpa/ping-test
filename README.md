# ping-test

A cross-platform network connectivity testing utility that performs ICMP ping tests to predefined sites and generates timestamped results with comprehensive device information.

This is especially useful when evaluating network configurations and need to test against the same criteria multiple times. Edit the script to add the websites or IP addresses relevant to your tests, then run and see the results in the terminal and saved as a timestamped text file.

## Table of Contents

- [1. Features](#1-features)
- [2. Technical Details](#2-technical-details)
- [3. Platform Support](#3-platform-support)
  - [3.1 macOS](#31-macos)
  - [3.2 Windows](#32-windows)
  - [3.3 Linux](#33-linux)
- [4. Setup](#4-setup)
  - [4.1 Make Scripts Executable (macOS/Linux)](#41-make-scripts-executable-macoslinux)
  - [4.2 PowerShell Execution Policy (Windows)](#42-powershell-execution-policy-windows)
- [5. Customisation](#5-customisation)
- [6. Output Format](#6-output-format)
- [7. AI Disclosure](#7-ai-disclosure)
- [8. License](#8-license)

## 1. Features

- **Cross-platform support**: Native scripts for macOS, Windows (PowerShell), and Linux
- **True ICMP ping tests**: Uses native ping commands for accurate network measurement (not HTTP-based)
- **Comprehensive device information**: Network configuration, IP addresses, DNS servers, OS details
- **Flexible output modes**: Full device info + ping tests, or ping tests only
- **Timestamped results**: Automatic file naming with precise execution timestamp
- **Real-time display**: Results shown in terminal and saved to file simultaneously

## 2. Technical Details

**Default Test Configuration:**

- **Sites tested**: 1.1.1.1, 8.8.8.8, google.com, testmyping.com, github.com
- **Ping count**: 5 packets per site
- **Output format**: `PingTest_YYYYMMDD_HHMMSS.txt`

**Device Information Collected:**

- Public IP address (via ifconfig.me)
- Local IP address, subnet mask, default gateway
- DNS servers configuration
- Network interface details (Wi-Fi SSID, connection type)
- System information (hostname, OS version)

## 3. Platform Support

### 3.1 macOS

**File**: `pingtest-macos.sh`

```bash
# Full test with device information
sh pingtest-macos.sh

# Ping tests only (no device info)
sh pingtest-macos.sh -l
```

### 3.2 Windows

**File**: `pingtest-windows.ps1`
*Note: May require PowerShell execution policy changes*

```powershell
# Full test with device information
.\pingtest-windows.ps1

# Ping tests only (no device info)
.\pingtest-windows.ps1 -l
```

### 3.3 Linux

**File**: `pingtest-linux.sh`

```bash
# Full test with device information
./pingtest-linux.sh

# Ping tests only (no device info)
./pingtest-linux.sh -l
```

## 4. Setup

### 4.1 Make Scripts Executable (macOS/Linux)

```bash
chmod +x pingtest-macos.sh pingtest-linux.sh
```

### 4.2 PowerShell Execution Policy (Windows)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 5. Customisation

The test sites and ping count can be easily modified by editing the `websites` array and `ping_count` variable in each script:

```bash
websites=("1.1.1.1" "8.8.8.8" "your-custom-site.com")
ping_count=5
```

## 6. Output Format

Results are displayed in terminal and saved to timestamped files in the same directory:

```text
Tests run at: 20240731 143022

Public IP Address: 203.0.113.45
Local IP Address: 192.168.1.100
Subnet: 255.255.255.0
Router: 192.168.1.1
DNS Servers: 8.8.8.8, 8.8.4.4
Hostname: MacBook-Pro.local
Network Name (SSID): MyNetwork
Connection Type: Wi-Fi
Operating System: macOS
Operating System Version: 14.5

Pinging 1.1.1.1...
PING 1.1.1.1 (1.1.1.1): 56 data bytes
64 bytes from 1.1.1.1: icmp_seq=0 ttl=60 time=5.083 ms
...
```

## 7. AI Disclosure

This application was developed with assistance from artificial intelligence tools. While the initial concept, direction, and architectural decisions were human-driven, AI was utilised to help write and refine portions of the codebase. This collaboration between human and AI development approaches was chosen to enhance development efficiency while maintaining human oversight of the project's goals and quality standards.

## 8. License

This project is released under [The Unlicense](https://github.com/thumpa/ping-test/blob/main/LICENSE), which allows anyone to freely use, modify, and distribute this software for any purpose without restriction.
