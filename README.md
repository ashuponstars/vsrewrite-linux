# vsrewrite-linux

a linux port of **vs rewrite**: the mod plus the psych engine 0.7.3 fork it runs on, reworked so the mod's window tricks (resizing, moving the window, the see-through desktop part) work on linux.

**v1 experimental.** it runs well on my pc but it's new, so if something breaks on yours, open an issue.

the mod isn't mine, it's made by springless, jaspercat, snowthefox, dapootisbird and the voice actors (full list in the mod's credits screen and [NOTICE.md](NOTICE.md)). it's in `mods/Sonic` with the team's permission, plus one tiny crash guard (see NOTICE.md). please support them.

## download and run

there's nothing to install, the release is a prebuilt game folder.

1. download the latest `vsrewrite-linux` archive from [releases](../../releases) and extract it. the mod is already inside
2. the mod's videos need the vlc libraries. fedora: `sudo dnf install vlc-libs` (rpmfusion). debian/ubuntu: `sudo apt install libvlc5 vlc-plugin-base`
3. run `./run.sh` in the folder

if something breaks, attach `vsrewrite-log.txt` (it's written next to the game) to your issue.

this repo is the source. cloning it doesn't give you a runnable game, for that use a release or follow [BUILDING.md](BUILDING.md).

## needs

- linux, x11 or wayland (runs through xwayland, so kde, gnome, hyprland, sway, i3 etc need no config)
- glibc 2.34+ (ubuntu 22.04+, debian 12+, fedora 35+, rhel 9, arch)
- a compositor for the see-through desktop part (all wayland sessions have one, on x11 run kwin/picom/mutter). without one that part is black

tested on **fedora + hyprland** only so far. kde, gnome, sway, i3 and other distros should work but i haven't run them yet.

## what works

window sizing and shaking, the see-through desktop section (wallpaper shows through, fake error window fades like on windows), end credits fullscreen and back, restarts/game over keeping the right size, and lower ram use.

**floating:** no window rules needed, the launcher tags the window as a dialog so tiling wms float it. `VSR_NO_DIALOG=1 ./run.sh` turns that off.

**desktop bar:** while the desktop is covered the game hides your bar and brings it back when it's visible. it runs your own `hide-bar.sh` / `restore-bar.sh` next to `run.sh` if you make them (examples in `examples/`, mine is `qs -c ii ipc call bar close|open`). otherwise `bar-auto.sh` detects quickshell, waybar, polybar, plasma panels, or any other bar (closes it and relaunches it after). i've only tested my own quickshell setup, the rest are untested. hyprland users can also set `coverBar` to fullscreen over the bar.

## debug build

separate small download (`vsrewrite-linux-debug-*.tar.xz`), drop it over a release install. adds test hooks and a memory/fps logger, see [docs/DEBUG.md](docs/DEBUG.md). `./test-trinity.sh` jumps to just before trinity's widescreen part. it's the same fast build, "debug" just means the extra hooks.

## known stuff

- trinity uses about 1.5 gb ram on integrated graphics, the mod's sprite sheets are huge
- `oh no its returning null` in the log is harmless (images the mod asks for that don't exist)
- a single frame can fail to draw once per screen change, recovers next frame, invisible
- native wayland isn't supported (windows can't position themselves there)

## more

[BUILDING.md](BUILDING.md), [docs/CHANGES.md](docs/CHANGES.md) (what changed vs upstream psych). thanks to [psych engine](https://github.com/ShadowMario/FNF-PsychEngine) (shadowmario + team) and everyone credited in the mod. license: apache 2.0 for the engine, see `LICENSE` / `NOTICE.md`.
