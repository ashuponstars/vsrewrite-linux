#!/bin/bash
# vs rewrite (linux) launcher. run it from anywhere: ./run.sh
cd "$(dirname "$(readlink -f "$0")")"
chmod +x PsychEngine 2>/dev/null

# the game moves and resizes its own window, native wayland can't do that, so use xwayland
export SDL_VIDEODRIVER="${SDL_VIDEODRIVER:-x11}"

# use the system vlc libs if they're installed, otherwise the ones in ./vlc (if you made that folder)
if ! { ldconfig -p 2>/dev/null || /sbin/ldconfig -p 2>/dev/null; } | grep -q 'libvlc\.so\.5'; then
  if [ -d "$PWD/vlc" ]; then
    export LD_LIBRARY_PATH="$PWD/vlc:$LD_LIBRARY_PATH"
    export VLC_PLUGIN_PATH="$PWD/vlc/plugins"
  else
    echo "libvlc.so.5 not found. install vlc (fedora: vlc-libs from rpmfusion, debian/ubuntu: libvlc5 vlc-plugin-base)" >&2
  fi
fi

# floating: libvsr_argb.so tags the window as a dialog so tiling wms float it with no config (VSR_NO_DIALOG=1 to disable)

# the see-through desktop part needs a 32-bit argb x visual, otherwise the compositor shows black instead of your
# wallpaper. libvsr_argb.so makes sdl pick that visual. VSR_NO_ARGB=1 runs without it.
PRE=""
if [ -z "$VSR_NO_ARGB" ] && [ -f "$PWD/libvsr_argb.so" ]; then PRE="$PWD/libvsr_argb.so"; fi

LD_PRELOAD="$PRE${LD_PRELOAD:+:$LD_PRELOAD}" ./PsychEngine "$@" 2>&1 | tee "$PWD/vsrewrite-log.txt"
