#!/usr/bin/env bash
set -euo pipefail

echo "[serjou][rust] Installing Rust via rustup"

if command -v rustc >/dev/null 2>&1; then
	echo "[serjou][rust] Rust already installed: $(rustc --version)"
	exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
	echo "[serjou][rust] curl is required but not found" >&2
	exit 1
fi

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Source cargo env so rustc/cargo are available immediately
if [[ -f "$HOME/.cargo/env" ]]; then
	# shellcheck disable=SC1091
	source "$HOME/.cargo/env"
fi

if command -v rustc >/dev/null 2>&1; then
	echo "[serjou][rust] Installed successfully: $(rustc --version)"
	echo "[serjou][rust] cargo: $(cargo --version)"
else
	echo "[serjou][rust] Installation finished but rustc is not available in PATH"
	exit 1
fi
