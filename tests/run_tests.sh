#!/bin/bash
# amalgame-io-filesystem — test runner (self-contained: amc + libgc).
set -u
PKG_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AMC=""
if   [ -n "${1:-}" ];                   then AMC="$1"
elif command -v amc >/dev/null 2>&1;    then AMC="$(command -v amc)"
elif [ -x "$PKG_DIR/../Amalgame/amc" ]; then AMC="$PKG_DIR/../Amalgame/amc"
elif [ -x "$HOME/.local/bin/amc" ];     then AMC="$HOME/.local/bin/amc"
fi
[ -x "$AMC" ] || { echo "error: amc not found"; exit 2; }
RUNTIME_DIR=""
if   [ -n "${AMC_RUNTIME:-}" ] && [ -d "$AMC_RUNTIME" ]; then RUNTIME_DIR="$AMC_RUNTIME"
elif [ -d "$PKG_DIR/../Amalgame/runtime" ];             then RUNTIME_DIR="$PKG_DIR/../Amalgame/runtime"
elif [ -d "$HOME/.amalgame/runtime" ];                  then RUNTIME_DIR="$HOME/.amalgame/runtime"
fi
BUILD_DIR=$(mktemp -d); trap 'rm -rf "$BUILD_DIR" "$PKG_DIR/_fstest"' EXIT
GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'
cd "$PKG_DIR"
INC="-Iruntime -I$RUNTIME_DIR -I."

"$AMC" --lib -o "$BUILD_DIR/facade" facade.am >/dev/null 2>&1
gcc -O2 $INC -c "$BUILD_DIR/facade.c" -o "$BUILD_DIR/facade.o" 2>"$BUILD_DIR/e" \
    || { echo -e "${RED}facade build failed${NC}"; cat "$BUILD_DIR/e"; exit 1; }

echo -e "\n── filesystem tests ──"
"$AMC" -o "$BUILD_DIR/t" tests/filesystem_test.am --external facade.am >/dev/null 2>"$BUILD_DIR/e" \
    || { echo -e "${RED}test compile failed${NC}"; cat "$BUILD_DIR/e"; exit 1; }
gcc -O2 $INC "$BUILD_DIR/t.c" "$BUILD_DIR/facade.o" -lgc -lm -o "$BUILD_DIR/t" 2>"$BUILD_DIR/e" \
    || { echo -e "${RED}test link failed${NC}"; cat "$BUILD_DIR/e"; exit 1; }
OUT="$("$BUILD_DIR/t")"; echo "$OUT"
echo "$OUT" | grep -q "\[FAIL\]" && { echo -e "${RED}FAILED${NC}"; exit 1; }

echo -e "\n${GREEN}All tests passed${NC}"
