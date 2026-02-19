#!/usr/bin/env bash
set -euo pipefail

echo "[serjou][git] Installing Git"

if command -v git >/dev/null 2>&1; then
	echo "[serjou][git] Git already installed: $(git --version)"
	exit 0
fi

if [[ $EUID -ne 0 ]]; then
	SUDO="sudo"
else
	SUDO=""
fi

install_with_apt() {
	$SUDO apt-get update
	$SUDO apt-get install -y git
}

install_with_dnf() {
	$SUDO dnf install -y git
}

install_with_yum() {
	$SUDO yum install -y git
}

install_with_pacman() {
	$SUDO pacman -Sy --noconfirm git
}

install_with_apk() {
	$SUDO apk add git
}

install_with_zypper() {
	$SUDO zypper --non-interactive install git
}

install_with_brew() {
	brew install git
}

OS="$(uname -s)"

case "$OS" in
	Darwin)
		if command -v brew >/dev/null 2>&1; then
			install_with_brew
		else
			echo "[serjou][git] Homebrew is required on macOS to install Git automatically."
			echo "[serjou][git] Install Homebrew: https://brew.sh"
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
			echo "[serjou][git] Unsupported Linux distribution: no known package manager found"
			exit 1
		fi
		;;
	*)
		echo "[serjou][git] Unsupported OS: $OS"
		exit 1
		;;
esac

if command -v git >/dev/null 2>&1; then
	echo "[serjou][git] Installed successfully: $(git --version)"
else
	echo "[serjou][git] Installation finished but git is not available in PATH"
	exit 1
fi
