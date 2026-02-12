#!/usr/bin/env bash
set -euo pipefail

# Installs Go from official binaries, optionally using GOVERSION (e.g., 1.22.4).

GOVERSION="${GOVERSION:-}"

if [[ -z "$GOVERSION" ]]; then
	# Fetch the latest stable version from go.dev.
	GOVERSION="$(curl -fsSL https://go.dev/VERSION?m=text | head -n 1 | sed 's/^go//')"
fi

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$ARCH" in
	x86_64|amd64) ARCH="amd64" ;;
	arm64|aarch64) ARCH="arm64" ;;
	*)
		echo "Unsupported architecture: $ARCH" >&2
		exit 1
		;;
esac

case "$OS" in
	darwin)
		TARBALL="go${GOVERSION}.darwin-${ARCH}.tar.gz"
		;;
	linux)
		TARBALL="go${GOVERSION}.linux-${ARCH}.tar.gz"
		;;
	*)
		echo "Unsupported OS: $OS" >&2
		exit 1
		;;
esac

URL="https://go.dev/dl/${TARBALL}"
TMPDIR="$(mktemp -d)"

cleanup() {
	rm -rf "$TMPDIR"
}
trap cleanup EXIT

echo "Downloading $URL"
curl -fL "$URL" -o "$TMPDIR/$TARBALL"

if [[ "$OS" == "darwin" ]]; then
	INSTALL_DIR="/usr/local"
else
	INSTALL_DIR="/usr/local"
fi

if [[ $EUID -ne 0 ]]; then
	SUDO="sudo"
else
	SUDO=""
fi

echo "Installing Go $GOVERSION to $INSTALL_DIR"
$SUDO rm -rf "$INSTALL_DIR/go"
$SUDO tar -C "$INSTALL_DIR" -xzf "$TMPDIR/$TARBALL"

cat <<'EOF'
Go installed.

Add to your shell profile if needed:
	export PATH="$PATH:/usr/local/go/bin"

Verify:
	go version
EOF
