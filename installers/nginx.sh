#!/usr/bin/env bash
set -euo pipefail

echo "[serjou][nginx] Installing nginx"

if command -v nginx >/dev/null 2>&1; then
	echo "[serjou][nginx] nginx already installed: $(nginx -v 2>&1)"
	exit 0
fi

if [[ $EUID -ne 0 ]]; then
	SUDO="sudo"
else
	SUDO=""
fi

install_with_apt() {
	$SUDO apt-get update
	$SUDO apt-get install -y nginx
}

install_with_dnf() {
	$SUDO dnf install -y nginx
}

install_with_yum() {
	$SUDO yum install -y nginx
}

install_with_pacman() {
	$SUDO pacman -Sy --noconfirm nginx
}

install_with_apk() {
	$SUDO apk add nginx
}

install_with_zypper() {
	$SUDO zypper --non-interactive install nginx
}

install_with_brew() {
	brew install nginx
}

OS="$(uname -s)"

case "$OS" in
	Darwin)
		if command -v brew >/dev/null 2>&1; then
			install_with_brew
		else
			echo "[serjou][nginx] Homebrew is required on macOS to install nginx automatically."
			echo "[serjou][nginx] Install Homebrew: https://brew.sh"
			exit 1
		fi
		;;
	Linux)
		if command -v apt-get >/dev/null 2>&1; then
			install_with_apt
		elif command -v dnf >/dev/null 2>&1; then
			install_with_dnf
		elif command -v yum >/dev/null 2>&1; then
			install_with_yum
		elif command -v pacman >/dev/null 2>&1; then
			install_with_pacman
		elif command -v apk >/dev/null 2>&1; then
			install_with_apk
		elif command -v zypper >/dev/null 2>&1; then
			install_with_zypper
		else
			echo "[serjou][nginx] Unsupported Linux distribution: no known package manager found"
			exit 1
		fi
		;;
	*)
		echo "[serjou][nginx] Unsupported OS: $OS"
		exit 1
		;;
esac

if command -v nginx >/dev/null 2>&1; then
	echo "[serjou][nginx] Installed successfully: $(nginx -v 2>&1)"
else
	echo "[serjou][nginx] Installation finished but nginx is not available in PATH"
	exit 1
fi

if command -v systemctl >/dev/null 2>&1; then
	if $SUDO systemctl list-unit-files | grep -q '^nginx\.service'; then
		$SUDO systemctl enable nginx >/dev/null 2>&1 || true
		$SUDO systemctl start nginx >/dev/null 2>&1 || true
		echo "[serjou][nginx] nginx service enabled and started"
	fi
fi
