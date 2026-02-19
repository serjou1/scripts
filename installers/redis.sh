#!/usr/bin/env bash
set -euo pipefail

echo "[serjou][redis] Installing Redis"

if command -v redis-server >/dev/null 2>&1; then
	echo "[serjou][redis] Redis already installed: $(redis-server --version | head -n 1)"
	exit 0
fi

if [[ $EUID -ne 0 ]]; then
	SUDO="sudo"
else
	SUDO=""
fi

install_with_apt() {
	$SUDO apt-get update
	$SUDO apt-get install -y redis-server
}

install_with_dnf() {
	$SUDO dnf install -y redis
}

install_with_yum() {
	$SUDO yum install -y redis
}

install_with_pacman() {
	$SUDO pacman -Sy --noconfirm redis
}

install_with_apk() {
	$SUDO apk add redis
}

install_with_zypper() {
	$SUDO zypper --non-interactive install redis
}

install_with_brew() {
	brew install redis
}

OS="$(uname -s)"

case "$OS" in
	Darwin)
		if command -v brew >/dev/null 2>&1; then
			install_with_brew
		else
			echo "[serjou][redis] Homebrew is required on macOS to install Redis automatically."
			echo "[serjou][redis] Install Homebrew: https://brew.sh"
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
			echo "[serjou][redis] Unsupported Linux distribution: no known package manager found"
			exit 1
		fi
		;;
	*)
		echo "[serjou][redis] Unsupported OS: $OS"
		exit 1
		;;
esac

if command -v redis-server >/dev/null 2>&1; then
	echo "[serjou][redis] Installed successfully: $(redis-server --version | head -n 1)"
else
	echo "[serjou][redis] Installation finished but redis-server is not available in PATH"
	exit 1
fi

if command -v systemctl >/dev/null 2>&1; then
	if $SUDO systemctl list-unit-files | grep -q '^redis\(-server\)\?\.service'; then
		$SUDO systemctl enable redis-server >/dev/null 2>&1 || true
		$SUDO systemctl enable redis >/dev/null 2>&1 || true
		$SUDO systemctl start redis-server >/dev/null 2>&1 || true
		$SUDO systemctl start redis >/dev/null 2>&1 || true
		echo "[serjou][redis] Redis service enabled and started (when service unit is available)"
	fi
fi

