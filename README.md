# vsrewrite-linux

linux build of the engine vs rewrite runs on. it's a psych engine 0.7.3 fork, reworked so the mod's window stuff (resizing, moving the window around, the see-through desktop part) actually works on linux instead of just windows.

**the vs rewrite mod isn't mine.** it's made by springless, jaspercat, snowthefox, dapootisbird and the voice actors (full list in the mod's own credits screen and [NOTICE.md](NOTICE.md)). it's in `mods/Sonic` (one tiny crash guard added, see NOTICE.md), put here with the team's permission so the port has everything it needs in one place. if you like it, go support them.

## what works

tested on **fedora + hyprland** (through xwayland). kde, gnome, sway, i3 and other distros are set up to work but i haven't run them myself yet, so say if something's off.

- window sizes and the menu / song / game over resizing
- songs that move and shake the window
- the see-through desktop section: your wallpaper shows through the window, the red static stays inside the rip, the fake error window fades out like it does on windows
- hiding your desktop bar (quickshell, waybar, whatever) while the game is fullscreen, and bringing it back whenever the desktop is visible
- restarting or dying mid song keeps the right window size
- end credits go fullscreen and the window comes back properly at the menu
- ram: image copies get freed after they're uploaded to the gpu, and memory goes back to the system after you leave a song

## what you need

- linux with xwayland or an x11 session. kde (plasma wayland and x11), gnome, hyprland, sway, i3 etc, the game picks x11 mode itself (through xwayland on wayland sessions)
- glibc 2.34 or newer (ubuntu 22.04+, debian 12+, fedora 35+, rhel/alma 9, arch). older than that, build from source
- vlc libs (`libvlc.so.5`), for the mod's videos. fedora: `sudo dnf install vlc-libs` (rpmfusion). debian/ubuntu: `sudo apt install libvlc5 vlc-plugin-base`
- a compositor for the see-through desktop section. wayland sessions all have one, on x11 you need one running (kwin, picom, mutter...). without one that part shows black instead of your wallpaper

## install

1. grab `vsrewrite-linux-release-*.tar.xz` from the releases page and extract it
2. make sure the mod is in `mods/` (so you end up with `mods/Sonic/`). it's already there if you cloned the repo
3. `./run.sh`

it also writes a log to `vsrewrite-log.txt` next to the game, attach that if you report a bug.

### window rules

you don't need any. the launcher tags the window as a dialog so tiling wms (hyprland, sway, i3, bspwm...) float it on their own, and the game centres itself. `VSR_NO_DIALOG=1 ./run.sh` turns that off if your wm hates it.

### hiding your desktop bar

during trinity's fullscreen part the game can hide your bar and show it again when the desktop is visible. it does that by running two little scripts next to `run.sh`:

- `hide-bar.sh`, run when the bar should go away
- `restore-bar.sh`, run when it should come back

there are examples in `examples/`. quickshell (end-4 style config named `ii`) is the one i use:

```sh
qs -c ii ipc call bar close   # hide-bar.sh
qs -c ii ipc call bar open    # restore-bar.sh
```

if you don't make those scripts the game tries `bar-auto.sh`, which detects whatever bar is running and hides it: quickshell (via its ipc, else restart), waybar, polybar, kde plasma panels, and any other bar by stopping it and starting it again with the same command. your own scripts still win if you make them. only the waybar and quickshell-ii paths have been reasoned about, none of the others are tested on a real desktop yet. there's also a `coverBar` setting (off by default, no menu toggle yet) that makes hyprland put the game in compositor fullscreen over the bar instead.

## debug vs release

- **release**: the normal one. no test hooks, no extra logging.
- **debug**: same game plus test hooks and a memory + fps logger. it's an overlay for the release folder, drop its files over a release install. see [docs/DEBUG.md](docs/DEBUG.md). `./test-trinity.sh` jumps straight to ~10 seconds before trinity goes widescreen so you don't have to play the whole song every time you test.

both are optimised builds. "debug" here means the test hooks, not a slow `-debug` compile.

## known stuff

- only tested on fedora + hyprland so far
- trinity uses a lot of ram, around 1.5 gb on integrated graphics, because the mod's character sheets are huge (the rewrite sheet alone is about 150 mb in memory). i checked and the sheets are already tightly packed, so there's nothing to trim without changing how they look
- the log has a few `oh no its returning null` lines for images the mod's scripts ask for that don't exist. harmless
- once per screen change a single frame can fail to draw and the game recovers on the next one. you can't see it
- native wayland isn't supported, it runs through xwayland because native wayland windows can't place or move themselves

## building

see [BUILDING.md](BUILDING.md). what changed vs upstream psych is in [docs/CHANGES.md](docs/CHANGES.md).

## credits

- [psych engine](https://github.com/ShadowMario/FNF-PsychEngine) by shadowmario and the psych team (apache 2.0), this is a fork of 0.7.3
- springless, jaspercat, snowthefox, dapootisbird and everyone else credited in the mod, for vs rewrite itself. the mod is theirs, this repo only ports the engine it runs on

license: apache 2.0, same as psych. see `LICENSE` and `NOTICE.md`.
