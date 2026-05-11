#!/usr/bin/env bash
# nvm's scripts reference unbound variables, so we avoid `set -u` globally
# and only enable strict failure modes.
set -eo pipefail

echo "[serjou][node] Installing Node.js LTS via nvm"

NVM_VERSION="v0.40.1"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

load_nvm() {
	if [[ -s "$NVM_DIR/nvm.sh" ]]; then
		# shellcheck disable=SC1091
		\. "$NVM_DIR/nvm.sh"
	fi
}

load_nvm

if command -v nvm >/dev/null 2>&1 && nvm ls --no-colors 'lts/*' >/dev/null 2>&1; then
	echo "[serjou][node] Node.js LTS already installed: $(node -v)"
	exit 0
fi

if ! command -v curl >/dev/null 2>&1; then
	echo "[serjou][node] curl is required but not found" >&2
	exit 1
fi

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
	echo "[serjou][node] Installing nvm $NVM_VERSION"
	curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
	load_nvm
fi

if ! command -v nvm >/dev/null 2>&1; then
	echo "[serjou][node] nvm installation finished but nvm is not available" >&2
	exit 1
fi

nvm install --lts
nvm alias default 'lts/*'

if command -v node >/dev/null 2>&1; then
	echo "[serjou][node] Installed successfully: $(node -v)"
	echo "[serjou][node] npm: $(npm -v)"
	echo "[serjou][node] Open a new shell or run: source \"$NVM_DIR/nvm.sh\""
else
	echo "[serjou][node] Installation finished but node is not available in PATH" >&2
	exit 1
fi
