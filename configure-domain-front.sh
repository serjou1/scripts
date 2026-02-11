#!/bin/bash

set -euo pipefail

usage() {
	echo "Usage: $0 -d domain -f file_path"
	echo "  -d, --domain   Domain name (e.g. example.com)"
	echo "  -f, --file     File to serve (e.g. /home/app/dist/index.html)"
}

CUSTOM_DOMAIN=""
TARGET_FILE=""

while [[ $# -gt 0 ]]; do
	case "$1" in
		-d|--domain)
			CUSTOM_DOMAIN="$2"
			shift 2
			;;
		-f|--file)
			TARGET_FILE="$2"
			shift 2
			;;
		-h|--help)
			usage
			exit 0
			;;
		*)
			echo "Unknown option: $1"
			usage
			exit 1
			;;
	esac
done

if [[ -z "$CUSTOM_DOMAIN" || -z "$TARGET_FILE" ]]; then
	echo "Domain and file are required."
	usage
	exit 1
fi

if [[ ! -f "$TARGET_FILE" ]]; then
	echo "Target file not found: $TARGET_FILE"
	exit 1
fi

DOC_ROOT="$(dirname "$TARGET_FILE")"
INDEX_FILE="$(basename "$TARGET_FILE")"

OUTPUT_FILE="/etc/nginx/sites-available/$CUSTOM_DOMAIN"

cat <<EOF | sudo tee "$OUTPUT_FILE" >/dev/null
server {
	listen 80;
	server_name $CUSTOM_DOMAIN;

	root $DOC_ROOT;
	index $INDEX_FILE;

	location / {
		try_files \$uri /$INDEX_FILE;
	}
}
EOF

echo "Configuration written to $OUTPUT_FILE"

if [[ -L "/etc/nginx/sites-enabled/$CUSTOM_DOMAIN" ]]; then
	sudo rm -f "/etc/nginx/sites-enabled/$CUSTOM_DOMAIN"
fi

sudo ln -s "$OUTPUT_FILE" "/etc/nginx/sites-enabled/$CUSTOM_DOMAIN"

sudo nginx -t
if [ $? -eq 0 ]; then
	echo "Nginx configuration is valid. Reloading Nginx..."
	sudo systemctl reload nginx
else
	echo "Nginx configuration is invalid. Please check the configuration."
	exit 1
fi

sudo certbot --nginx -d "$CUSTOM_DOMAIN"
