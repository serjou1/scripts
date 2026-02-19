#!/usr/bin/env bash
set -euo pipefail

echo "[serjou][node] Installing Node.js"

if command -v node >/dev/null 2>&1; then
	echo "[serjou][node] Node.js already installed: $(node -v)"
	exit 0
fi

if [[ $EUID -ne 0 ]]; then
	SUDO="sudo"
else
	SUDO=""
fi

install_with_apt() {
	$SUDO apt-get update
	$SUDO apt-get install -y nodejs npm
}

install_with_dnf() {
	$SUDO dnf install -y nodejs npm
}

install_with_yum() {
	$SUDO yum install -y nodejs npm
}

install_with_pacman() {
	$SUDO pacman -Sy --noconfirm nodejs npm
}

install_with_apk() {
	$SUDO apk add nodejs npm
}

install_with_zypper() {
	$SUDO zypper --non-interactive install nodejs npm
}

install_with_brew() {
	brew install node
}

OS="$(uname -s)"

case "$OS" in
	Darwin)
		if command -v brew >/dev/null 2>&1; then
			install_with_brew
		else
			echo "[serjou][node] Homebrew is required on macOS to install Node.js automatically."
			echo "[serjou][node] Install Homebrew: https://brew.sh"
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
			echo "[serjou][node] Unsupported Linux distribution: no known package manager found"
			exit 1
		fi
		;;
	*)
		echo "[serjou][node] Unsupported OS: $OS"
		exit 1
		;;
esac

if command -v node >/dev/null 2>&1; then
	echo "[serjou][node] Installed successfully: $(node -v)"
	if command -v npm >/dev/null 2>&1; then
		echo "[serjou][node] npm: $(npm -v)"
	fi
else
	echo "[serjou][node] Installation finished but node is not available in PATH"
	exit 1
fi
