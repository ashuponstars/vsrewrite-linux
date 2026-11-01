#!/bin/bash
# usage: scripts/build.sh [release|debug]
# release = normal build. debug = same optimised build plus the test hooks and the memory/fps logger (-Dvsr_debug).
set -e
FLAVOUR="${1:-release}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
export HAXELIB_PATH="$HERE/build/haxelib"
EXTRA=""
[ "$FLAVOUR" = "debug" ] && EXTRA="-Dvsr_debug"
cd "$HERE/build/psych"
# "yes N" answers lime's "install missing deps?" prompts with no
yes N | haxelib run lime build linux -release -nocolor $EXTRA
mkdir -p "$HERE/out/$FLAVOUR"
cp -r export/release/linux/bin/. "$HERE/out/$FLAVOUR/"
echo "built: $HERE/out/$FLAVOUR/PsychEngine"
