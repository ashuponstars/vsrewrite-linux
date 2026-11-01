#!/bin/bash
# sets up a build folder: upstream psych 0.7.3 + our source on top + pinned libs + the two library patches.
# you need haxe 4.3.6 on your PATH first (https://haxe.org/download/), plus git, patch, gcc/g++, make.
set -e
HERE="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$HERE/build"
mkdir -p "$BUILD"

if [ ! -d "$BUILD/psych" ]; then
  git clone --depth 1 --branch 0.7.3 https://github.com/ShadowMario/FNF-PsychEngine "$BUILD/psych"
fi

# our files go over upstream's (assets and art stay upstream's)
rm -rf "$BUILD/psych/source"
cp -r "$HERE/source" "$BUILD/psych/source"
cp "$HERE/Project.xml" "$HERE/hmm.json" "$HERE/hxformat.json" "$BUILD/psych/"

export HAXELIB_PATH="$BUILD/haxelib"
mkdir -p "$HAXELIB_PATH"
haxelib setup "$HAXELIB_PATH"

# these exact versions, newer ones break this old engine
for lv in lime:8.1.2 openfl:9.3.3 flixel:5.5.0 flixel-addons:3.2.2 flixel-ui:2.5.0 flixel-tools:1.5.1 SScript:7.7.0 hxvlc:2.1.4 tjson:1.4.0 hxcpp:4.3.2; do
  haxelib install "${lv%%:*}" "${lv##*:}" --always --skip-dependencies
done
haxelib git flxanimate https://github.com/ShadowMario/flxanimate dev
haxelib git linc_luajit https://github.com/superpowers04/linc_luajit
haxelib git hxdiscord_rpc https://github.com/MAJigsaw77/hxdiscord_rpc

# patches to the libraries (see docs/CHANGES.md for why)
patch -N -p1 -d "$HAXELIB_PATH/flixel/5,5,0" < "$HERE/patches/flixel-5.5.0-skip-null-graphic.patch" || true
patch -N -p1 -d "$HAXELIB_PATH/lime/8,1,2/src" < "$HERE/patches/lime-8.1.2-window-opacity.patch" || true

echo "setup done. now: scripts/build.sh release   (or: debug)"
