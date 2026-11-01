# vsrewrite-linux

linux port of vs rewrite. it's the mod plus the engine it runs on, reworked so the window stuff (resizing, moving the window, seeing your desktop through it) works on linux.

v1 experimental. runs well on my pc, if it breaks on yours open an issue and attach `vsrewrite-log.txt` (it's next to the game).

## run it

1. download the archive from [releases](../../releases) and extract it
2. run `./run.sh`

that's it, the mod and everything it needs (vlc included) is in the folder.

## needs

- glibc 2.34+ (ubuntu 22.04+, debian 12+, fedora 35+, rhel 9, arch)
- x11 or wayland, kde / gnome / hyprland / sway / i3 all fine, no config needed. it runs through xwayland
- a compositor for the see-through desktop part (every wayland session has one, on x11 use kwin/picom/mutter), otherwise that part is black

tested on fedora + hyprland so far. everything else should work but i haven't run it yet.

## good to know

- **floating:** no window rules needed, the window tags itself so tiling wms float it. `VSR_NO_DIALOG=1 ./run.sh` turns that off
- **bar:** the game hides your desktop bar while the desktop is covered and brings it back after. put your own `hide-bar.sh` and `restore-bar.sh` next to `run.sh` (examples in `examples/`), or `bar-auto.sh` guesses: quickshell, waybar, polybar, plasma panels, or it closes and relaunches any other bar. i've only tested my own quickshell
- trinity uses about 1.5 gb ram on integrated graphics, the sheets are huge
- `oh no its returning null` in the log is harmless
- native wayland isn't supported, windows can't position themselves there

## debug build

separate small download, drop it over the game folder. adds test hooks and a memory/fps logger ([docs/DEBUG.md](docs/DEBUG.md)). `./test-trinity.sh` jumps to just before trinity's widescreen part.

## source

this repo is the source (nothing runnable in it). [BUILDING.md](BUILDING.md) to build it, [docs/CHANGES.md](docs/CHANGES.md) for what changed vs upstream psych.

## credits

the mod is by springless, jaspercat, snowthefox, dapootisbird and the voice actors (full list in the mod's credits screen), included here with their permission plus one small crash guard (see [NOTICE.md](NOTICE.md)). please support them. engine is [psych engine](https://github.com/ShadowMario/FNF-PsychEngine) 0.7.3 by shadowmario and team. license: apache 2.0 for the engine, see `LICENSE`.
