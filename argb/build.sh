#!/bin/bash
# builds libvsr_argb.so. needs gcc and the x11 dev headers (debian: libx11-dev, fedora: libX11-devel)
cd "$(dirname "$0")"
gcc -shared -fPIC -O2 -o libvsr_argb.so vsr_argb.c -lX11 -ldl && echo "built libvsr_argb.so"
