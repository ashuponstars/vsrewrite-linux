# debug build

the debug build is the normal game plus test hooks and a logger. it's meant for testing, not for playing. drop its files over a release install (`PsychEngine`, `run.sh`, `test-trinity.sh`).

## test-trinity.sh

```sh
./test-trinity.sh            # 4x botplay, hands control back at step 3490
./test-trinity.sh 3          # 3x
./test-trinity.sh 4 3000     # 4x until step 3000
```

jumps straight into trinity, plays it with botplay at the speed you give, and at the step you give turns botplay off and goes back to normal speed. 4x works, much higher starts breaking things.

## environment variables

set these before `./run.sh`. all of them only exist in the debug build.

| variable | what it does |
|---|---|
| `VSR_SONG=trinity` | start straight in that song |
| `VSR_FF=rate,step` | with `VSR_SONG`: botplay at `rate` until `step`, then give control back at normal speed |
| `VSR_BOT=1` | botplay on |
| `VSR_RATE=2` | song speed |
| `VSR_SEEK=ms` | start the song at that time, events before it count as done |
| `VSR_SCRIPT=states/MainMenuState` | start on that screen |
| `VSR_CONTROLS=1` | open the controls screen after 2 seconds |
| `VSR_LAYERED=1` | after 6 s paint the key colour and switch the see-through window on (transparency test) |
| `VSR_LAYERED=2` | layering test: red camera underneath, a key coloured sprite on the left half on top |
| `VSR_INTERNAL=1` | forces the "internal" layers on at step 8 so they can be looked at |
| `VSR_SHOTSTEPS=2560,2640` | screenshots at those exact steps into `~/psych/shots/` (make the folder first, needs ffmpeg + x11) |
| `VSR_NO_ARGB=1` | run without the ARGB shim (works in release too) |
| `VSR_ARGB_DEBUG=1` | the shim prints what it picked (works in release too) |

## the [mem] log

every 5 seconds and on every screen change the game prints a line like this:

```
[mem] rss=1459324 kB gcheap=500MB images=132 cachedgraphics=140 fps=62 worstframe=22ms slowframes=0 state=states.PlayState
```

- `rss`: memory the process uses, as the system sees it. on integrated graphics gpu textures count in here
- `gcheap`: the game's own heap
- `images`: images the engine is tracking right now, `cachedgraphics`: everything in flixel's cache (text, solid colours...)
- `fps`: average over the last 5 s. `worstframe`: slowest single frame. `slowframes`: frames over 50 ms
- `state`: which screen you're on

a leak shows as `rss` and `gcheap` going up every time you change screens and never coming back down. loading a big song makes both jump and then level off, that's normal.

## other logs

- `[window] ...` lines: window size self-corrections and opacity changes
- `[ff] handed over at step N`: the fast forward ended
- `transparent window pixels rgba: ...`: what the see-through window really contains (alpha 0 = see-through)
- `[draw] frame failed`: a frame didn't draw, followed by a list of what was in it. the game recovers on its own
- `./run.sh` (debug) also writes `~/vsrewrite-xinfo.txt` with the x visual info, depth 32 means the see-through part can work
