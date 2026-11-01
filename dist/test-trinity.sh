#!/bin/bash
# DEBUG ONLY: starts trinity directly, plays it with botplay at 4x, and hands control back at step 3490
# (about 10 s before it goes widescreen). usage: ./test-trinity.sh [rate] [step]
cd "$(dirname "$(readlink -f "$0")")"
export VSR_SONG=trinity
export VSR_FF="${1:-4},${2:-3490}"
exec ./run.sh
