# building from source

only tested on linux (x86_64). the prebuilt binary needs glibc 2.38+, so if your distro is older, building it yourself is the way.

## what you need installed

- haxe **4.3.6** (https://haxe.org/download/), on your PATH
- git, patch, gcc, g++, make
- dev headers: libvlc (debian `libvlc-dev`, fedora `vlc-devel`), opengl (`libgl-dev`), x11 (`libx11-dev`)
- if the linker complains about a missing `-lsomething`, install that package's `-dev` / `-devel` version

## steps

```sh
git clone https://github.com/ashuponstars/vsrewrite-linux
cd vsrewrite-linux
scripts/setup.sh            # clones upstream psych 0.7.3, puts our source on top, installs the pinned libs, applies the 2 patches
scripts/build.sh release    # -> out/release/
scripts/build.sh debug      # -> out/debug/   (same thing + test hooks and the mem/fps logger)
scripts/package.sh 0.1.0    # -> dist-out/*.tar.xz
```

a full build is slow the first time (the c++ compile, 10+ minutes), after that it only rebuilds what changed.

## the pinned libraries

old engine, new library versions break it. `setup.sh` installs exactly:

| lib | version |
|---|---|
| lime | 8.1.2 |
| openfl | 9.3.3 |
| flixel | 5.5.0 |
| flixel-addons | 3.2.2 |
| flixel-ui | 2.5.0 |
| flixel-tools | 1.5.1 |
| SScript | 7.7.0 |
| hxvlc | 2.1.4 |
| tjson | 1.4.0 |
| hxcpp | 4.3.2 |
| flxanimate | git, branch dev |
| linc_luajit | git |
| hxdiscord_rpc | git |

## the two library patches

these get applied by `setup.sh` into the local `build/haxelib` folder (your system haxe libs aren't touched):

- `patches/flixel-5.5.0-skip-null-graphic.patch`: flixel crashed the whole frame when a sprite's image had been destroyed, now that one sprite is skipped
- `patches/lime-8.1.2-window-opacity.patch`: compositors often ignore window opacity, so on linux lime stores the value and the game fades the picture itself (this is how the fake error window fades out)

## debug vs release

`-Dvsr_debug` is the only difference. it turns on the `VSR_*` environment hooks and the `[mem]` logger (see [docs/DEBUG.md](docs/DEBUG.md)). without it all of that is compiled out.

## the ARGB shim

`argb/vsr_argb.c` is a tiny LD_PRELOAD library. sdl picks a 24-bit x visual by default and then the compositor can't see through the window. the shim makes it pick a 32-bit one. build it with `argb/build.sh` (needs gcc + libx11 dev headers). if you skip it the game still runs, the desktop section just shows black.
