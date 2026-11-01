# vsrewrite-linux

linux port of vs rewrite: the mod plus the engine it runs on, with the window stuff (resizing, moving, seeing your desktop through it) working on linux.

v1 experimental. if it breaks, open an issue with `vsrewrite-log.txt` (next to the game).

## run it

1. download from [releases](../../releases) and extract
2. `./run.sh`

mod and vlc are in the folder, nothing else to install.

## needs

- glibc 2.34+ (ubuntu 22.04+, debian 12+, fedora 35+, rhel 9, arch)
- x11 or wayland, any desktop, no config (runs through xwayland)
- a compositor for the see-through desktop part, else it's black. every wayland session has one, on x11 use kwin/picom/mutter

tested on fedora + hyprland only so far.

## good to know

- no window rules needed, the window tags itself so tiling wms float it. `VSR_NO_DIALOG=1 ./run.sh` turns that off
- the game hides your bar while the desktop is covered. use your own `hide-bar.sh` / `restore-bar.sh` next to `run.sh` (examples in `examples/`), or `bar-auto.sh` tries quickshell, waybar, polybar, plasma panels, or closes and relaunches any other bar. only my quickshell is tested
- i've tried my best to make this run well on low end hardware. you'll mostly hit 1-2gb of ram in trinity, other than that you should be good
- `oh no its returning null` in the log is harmless
- native wayland isn't supported, windows can't position themselves

## debug build

small separate download, drop it over the game folder. test hooks and a memory/fps logger ([docs/DEBUG.md](docs/DEBUG.md)). `./test-trinity.sh` jumps to just before trinity's widescreen part.

## source

[BUILDING.md](BUILDING.md) to build, [docs/CHANGES.md](docs/CHANGES.md) for changes vs upstream psych. the repo alone isn't runnable.

## credits

the mod is by springless, jaspercat, snowthefox, dapootisbird and the voice actors (see the mod's credits screen). included with their permission plus one small crash guard ([NOTICE.md](NOTICE.md)). please support them.

engine: [psych engine](https://github.com/ShadowMario/FNF-PsychEngine) 0.7.3 by shadowmario and team. apache 2.0, see `LICENSE`.
