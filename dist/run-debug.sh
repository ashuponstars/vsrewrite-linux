#!/bin/bash
# debug launcher. same as run.sh plus a window info dump (~/vsrewrite-xinfo.txt) and the log goes to ~/vsrewrite-log.txt
cd "$(dirname "$(readlink -f "$0")")"
chmod +x PsychEngine 2>/dev/null
export SDL_VIDEODRIVER="${SDL_VIDEODRIVER:-x11}"

if ! { ldconfig -p 2>/dev/null || /sbin/ldconfig -p 2>/dev/null; } | grep -q 'libvlc\.so\.5'; then
  if [ -d "$PWD/vlc" ]; then
    export LD_LIBRARY_PATH="$PWD/vlc:$LD_LIBRARY_PATH"
    export VLC_PLUGIN_PATH="$PWD/vlc/plugins"
  fi
fi

PRE=""
if [ -z "$VSR_NO_ARGB" ] && [ -f "$PWD/libvsr_argb.so" ]; then PRE="$PWD/libvsr_argb.so"; fi

# 25 s in, write what x thinks of the game window (depth 32 = the see-through part can work). needs xwininfo (x11-utils)
if command -v xwininfo >/dev/null 2>&1; then
  ( sleep 25
    { echo "--- window info $(date +%T) (preload: ${PRE:-none})"
      id=$(xwininfo -root -tree 2>/dev/null | grep -i -E "psychengine" | head -1 | awk '{print $1}')
      xwininfo -id "$id" 2>&1 | grep -E "xwininfo|Depth|Visual|Map State|Absolute|Width|Height"
    } > "$HOME/vsrewrite-xinfo.txt" 2>&1 ) &
fi

LD_PRELOAD="$PRE${LD_PRELOAD:+:$LD_PRELOAD}" ./PsychEngine "$@" 2>&1 | tee "$HOME/vsrewrite-log.txt"
