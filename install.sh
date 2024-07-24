#!/bin/bash

# Install dependencies
apt-get update
apt-get install -y bash systemd logrotate jq docker.io

SCRIPT_DIR=$(dirname "$(realpath "$0")")

if [ -f "$SCRIPT_DIR/devopsfetch.sh" ]; then

    chmod +x "$SCRIPT_DIR/devopsfetch.sh"
else
    echo "Error: devopsfetch.sh script not found!"
    exit 1
fi

if [ -f "$SCRIPT_DIR/devopsfetch.service" ]; then

    mkdir -p /etc/systemd/system/
    cp "$SCRIPT_DIR/devopsfetch.service" /etc/systemd/system/

    sed -i "s|ExecStart=.*|ExecStart=/usr/bin/bash $SCRIPT_DIR/devopsfetch.sh|" /etc/systemd/system/devopsfetch.service
else
    echo "Error: devopsfetch.service file not found!"
    exit 1
fi


systemctl daemon-reload


mkdir -p /etc/logrotate.d/
cat <<EOL > /etc/logrotate.d/devopsfetch
/var/log/devopsfetch.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0640 root adm
    sharedscripts
    postrotate
        systemctl restart devopsfetch > /dev/null
    endscript
}
EOL


systemctl start devopsfetch
systemctl enable devopsfetch
