#!/bin/bash
# Parse -h and -p parameters for hostname and port
while getopts "h:p:" opt; do
    case $opt in
        h) CUSTOM_HOSTNAME="$OPTARG";;
        p) CUSTOM_PORT="$OPTARG";;
         *) echo "Usage: $0 -h hostname -p port" && exit 1;;
    esac
done

echo "Hostname: $CUSTOM_HOSTNAME"
echo "Port: $CUSTOM_PORT"

if [[ -z "$CUSTOM_HOSTNAME" || -z "$CUSTOM_PORT" ]]; then
    echo "Hostname and Port are required. Usage: $0 -h hostname -p port"
    exit 1
fi

OUTPUT_FILE="/etc/nginx/sites-available/$CUSTOM_HOSTNAME"

cat <<EOF > "$OUTPUT_FILE"
server {
    listen 80;
    server_name $CUSTOM_HOSTNAME;

    location / {
        proxy_pass http://localhost:$CUSTOM_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

echo "Configuration written to $OUTPUT_FILE"

sudo ln -s $OUTPUT_FILE /etc/nginx/sites-enabled/

sudo nginx -t
if [ $? -eq 0 ]; then
    echo "Nginx configuration is valid. Reloading Nginx..."
    sudo systemctl reload nginx
else
    echo "Nginx configuration is invalid. Please check the configuration."
    exit 1
fi

sudo certbot --nginx -d $CUSTOM_HOSTNAME
