# DevOpsFetch

---

### Table of Contents
1. [Introduction](#introduction)
2. [Installation and Configuration](#installation-and-configuration)
3. [Usage Examples](#usage-examples)
    - [Ports](#ports)
    - [Docker](#docker)
    - [Nginx](#nginx)
    - [Users](#users)
    - [Time Range](#time-range)
4. [Logging Mechanism](#logging-mechanism)
    - [Log Retrieval](#log-retrieval)
5. [Troubleshooting](#troubleshooting)

---

### Introduction
DevOpsFetch is a versatile tool designed to retrieve and display system information including active ports, Docker images and containers, Nginx configurations, user details, and system activities within a specified time range. It formats outputs for readability and ensures comprehensive system monitoring.

### Installation and Configuration

#### Prerequisites
- A Debian-based or Ubuntu system.
- `sudo` privileges.

#### Steps

1. **Clone the Repository**
    ```bash
    git clone https://github.com/your-repo/devopsfetch.git
    cd devopsfetch
    ```

2. **Run the Installation Script**
    The installation script installs necessary dependencies, sets up the systemd service, and configures log rotation.
    ```bash
    sudo ./install.sh
    ```

    The `install.sh` script performs the following tasks:
    - Installs `bash`, `systemd`, `logrotate`, `jq`, and `docker.io`.
    - Copies `devopsfetch.sh` to `/usr/local/bin/` and sets the appropriate permissions.
    - Configures the systemd service for DevOpsFetch.
    - Configures log rotation for the DevOpsFetch logs.

#### Systemd Service Configuration

The systemd service file is located at `/etc/systemd/system/devopsfetch.service`. It contains:

```ini
[Unit]
Description=DevOps Fetch Service
After=network.target

[Service]
ExecStart=/usr/bin/bash /usr/local/bin/devopsfetch.sh
Restart=on-failure
User=root
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=devopsfetch

[Install]
WantedBy=multi-user.target
