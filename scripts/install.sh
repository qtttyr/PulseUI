#!/usr/bin/env sh
# PulseUI CLI installer — macOS & Linux, POSIX sh only.
#
#   curl -fsSL https://raw.githubusercontent.com/qtttyr/PulseUI/main/scripts/install.sh | bash
#
# Builds the `pulse` CLI from source on first run (requires Swift 6+)
# and drops the binary into ${PULSE_PREFIX:-~/.local/bin}.

set -e

REPO_URL=${PULSE_REPO_URL:-https://github.com/qtttyr/PulseUI.git}
PREFIX=${PULSE_PREFIX:-"${HOME}/.local/bin"}

quote() { printf '%s ' "$@"; }

echo "pulse — PulseUI installer"
echo "  source:  $REPO_URL"
echo "  prefix:  $PREFIX"
echo

command -v git >/dev/null 2>&1 || { echo "error: git is required" >&2; exit 1; }
command -v swift >/dev/null 2>&1 || { echo "error: Swift 6+ is required (https://swift.org)" >&2; exit 1; }

SWIFT_VERSION=$(swift --version 2>&1 | grep -o "Swift version [0-9.]*" | head -n1)
echo "  using:   $SWIFT_VERSION"
echo

TMPDIR_T=$(mktemp -d /tmp/pulse-install.XXXXXX)
trap 'rm -rf "$TMPDIR_T"' EXIT

echo "cloning $REPO_URL …"
git clone --depth 1 -q "$REPO_URL" "$TMPDIR_T/PulseUI"

echo "building release binary …"
(
  cd "$TMPDIR_T/PulseUI"
  swift build -c release --product pulse 2>/dev/null || swift build -c release
)

BIN_DIR=$(
  cd "$TMPDIR_T/PulseUI"
  swift build -c release --show-bin-path 2>/dev/null || true
)
BIN="$BIN_DIR/pulse"
if [ ! -x "$BIN" ]; then
  echo "error: build completed but no executable pulse binary was found." >&2
  echo "       expected: $BIN" >&2
  exit 1
fi

mkdir -p "$PREFIX"
install -m 0755 "$BIN" "$PREFIX/pulse"
echo
echo "installed: $PREFIX/pulse"
"$PREFIX/pulse" version

case ":$PATH:" in
  *":$PREFIX:"*) : ;;
  *)
    echo
    echo "note: pulse is installed, but $PREFIX is not on your PATH."
    echo "       add it permanently to your shell configuration:"
    echo "  export PATH=\"$PREFIX:\$PATH\""
    echo "       then open a new terminal or run that export command."
    ;;
esac

echo
echo "next:"
echo "  pulse init          # add PulseUI to your Swift package"
echo "  pulse add button toast alert && pulse list"