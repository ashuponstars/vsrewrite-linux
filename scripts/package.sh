#!/bin/bash
# usage: scripts/package.sh <version>   (after build.sh release and build.sh debug)
# makes dist-out/vsrewrite-linux-release-<v>.tar.xz (full game folder) and ...-debug-<v>.tar.xz (overlay for it)
set -e
VER="${1:?usage: package.sh <version>}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$HERE/dist-out"; mkdir -p "$OUT"
bash "$HERE/argb/build.sh"

R="$OUT/vsrewrite-linux-release-$VER"; rm -rf "$R"; mkdir -p "$R"
cp -r "$HERE/out/release/." "$R/"
rm -rf "$R/mods"; mkdir -p "$R/mods" "$R/examples"
echo "put the vs rewrite mod in here, so you end up with mods/Sonic/" > "$R/mods/README.txt"
cp "$HERE/dist/run.sh" "$R/run.sh"
cp "$HERE/dist/examples/"* "$R/examples/"
cp "$HERE/argb/libvsr_argb.so" "$R/"
cp "$HERE/README.md" "$HERE/LICENSE" "$HERE/NOTICE.md" "$R/"
chmod +x "$R/run.sh" "$R/PsychEngine"
tar -C "$OUT" -cJf "$OUT/vsrewrite-linux-release-$VER.tar.xz" "vsrewrite-linux-release-$VER"

D="$OUT/vsrewrite-linux-debug-$VER"; rm -rf "$D"; mkdir -p "$D"
cp "$HERE/out/debug/PsychEngine" "$D/PsychEngine"
cp "$HERE/dist/run-debug.sh" "$D/run.sh"
cp "$HERE/dist/test-trinity.sh" "$D/"
cp "$HERE/docs/DEBUG.md" "$D/"
chmod +x "$D/"*.sh "$D/PsychEngine"
tar -C "$OUT" -cJf "$OUT/vsrewrite-linux-debug-$VER.tar.xz" "vsrewrite-linux-debug-$VER"
echo "done: $OUT"
