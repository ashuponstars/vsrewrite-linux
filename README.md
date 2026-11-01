# vsrewrite-linux

linux build of the engine vs rewrite runs on. it's a psych engine 0.7.3 fork, reworked so the mod's window stuff (resizing, moving the window around, the see-through desktop part) actually works on linux instead of just windows.

**this is only the engine.** the vs rewrite mod itself is not in this repo and it isn't mine. grab it from the people who made it and put it in `mods/`. no mod files, no mod assets in here, ever.

## what works

tested on **fedora + hyprland** (through xwayland). that's the only setup i've actually run it on, so treat anything else as "should work, nobody checked".

- window sizes and the menu / song / game over resizing
- songs that move and shake the window
- the see-through desktop section: your wallpaper shows through the window, the red static stays inside the rip, the fake error window fades out like it does on windows
- hiding your desktop bar (quickshell, waybar, whatever) while the game is fullscreen, and bringing it back whenever the desktop is visible
- restarting or dying mid song keeps the right window size
- end credits go fullscreen and the window comes back properly at the menu
- ram: image copies get freed after they're uploaded to the gpu, and memory goes back to the system after you leave a song

## what you need

- linux with xwayland or an x11 session
- glibc 2.38 or newer (fedora 39+, ubuntu 24.04+, recent arch). older distros won't run the prebuilt binary, build from source instead
- vlc libs (`libvlc.so.5`), for the mod's videos. fedora: `sudo dnf install vlc-libs` (rpmfusion). debian/ubuntu: `sudo apt install libvlc5 vlc-plugin-base`
- a compositor that can do transparent windows for the desktop section (hyprland works)

## install

1. grab `vsrewrite-linux-release-*.tar.xz` from the releases page and extract it
2. copy the vs rewrite mod into `mods/` (so you end up with `mods/Sonic/`)
3. `./run.sh`

it also writes a log to `vsrewrite-log.txt` next to the game, attach that if you report a bug.

### hyprland

keep the game floating and centered. in a lua config:

```lua
hl.window_rule({match = {class = "^(PsychEngine)$" }, float = true})
hl.window_rule({match = {class = "^(PsychEngine)$" }, center = true})
```

or in the old `hyprland.conf` style:

```
windowrule = float, class:^(PsychEngine)$
windowrule = center, class:^(PsychEngine)$
```

(the second one i haven't tested, i run the lua config)

### hiding your desktop bar

during trinity's fullscreen part the game can hide your bar and show it again when the desktop is visible. it does that by running two little scripts next to `run.sh`:

- `hide-bar.sh`, run when the bar should go away
- `restore-bar.sh`, run when it should come back

there are examples in `examples/`. quickshell (end-4 style config named `ii`) is the one i use:

```sh
qs -c ii ipc call bar close   # hide-bar.sh
qs -c ii ipc call bar open    # restore-bar.sh
```

for waybar there's an untested example that toggles it with `SIGUSR1`. no scripts means your bar just stays where it is. there's also a `coverBar` setting (off by default, no menu toggle yet) that makes hyprland put the game in compositor fullscreen over the bar instead.

## debug vs release

- **release**: the normal one. no test hooks, no extra logging.
- **debug**: same game plus test hooks and a memory + fps logger. it's an overlay for the release folder, drop its files over a release install. see [docs/DEBUG.md](docs/DEBUG.md). `./test-trinity.sh` jumps straight to ~10 seconds before trinity goes widescreen so you don't have to play the whole song every time you test.

both are optimised builds. "debug" here means the test hooks, not a slow `-debug` compile.

## known stuff

- only tested on fedora + hyprland
- trinity uses a lot of ram, around 1.5 gb on integrated graphics, because the mod's character sheets are huge (the rewrite sheet alone is about 150 mb in memory). i checked and the sheets are already tightly packed, so there's nothing to trim without changing how they look
- the log has a few `oh no its returning null` lines for images the mod's scripts ask for that don't exist. harmless
- once per screen change a single frame can fail to draw and the game recovers on the next one. you can't see it
- native wayland isn't supported, it runs through xwayland because native wayland windows can't place or move themselves

## building

see [BUILDING.md](BUILDING.md). what changed vs upstream psych is in [docs/CHANGES.md](docs/CHANGES.md).

## credits

- [psych engine](https://github.com/ShadowMario/FNF-PsychEngine) by shadowmario and the psych team (apache 2.0), this is a fork of 0.7.3
- the vs rewrite team for the mod this runs. not included, not affiliated

license: apache 2.0, same as psych. see `LICENSE` and `NOTICE.md`.
