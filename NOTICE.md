# notice

this project is a fork of **psych engine 0.7.3** (https://github.com/ShadowMario/FNF-PsychEngine), licensed under the apache license 2.0 (see `LICENSE`). psych engine is by shadowmario and the psych engine team. files in this repo that came from psych engine keep their original license. our changes are listed in `docs/CHANGES.md` and the full diff is in `docs/changes-vs-upstream.diff`.

## the mod

the vs rewrite mod (everything in `mods/Sonic`) is **not** mine and isn't covered by this repo's license. it belongs to its creators: Springless, JasperCat, SnowTheFox, DaPootisBird, with voice acting by ahlyess, DylanZeMuffin, LandyRS and Sturm (see `mods/Sonic/data/credits.txt` for their links). it's included here with the permission of its creators, so the linux build can be run and tested. the only change is one line in `mods/Sonic/states/gallery/ComputerState.hx`: a null check so it doesn't crash if the video isn't loaded yet. it keeps its own terms. this project isn't affiliated with the mod or its team. if its creators want it removed, open an issue and it goes.

engine assets (`assets/`, `art/`) aren't in the source repo either, `scripts/setup.sh` fetches them from upstream. the release tarball includes upstream's assets unchanged.

## libraries

haxe, lime, openfl, flixel, flixel-addons, flixel-ui, hxcpp, SScript, hxvlc, linc_luajit, hxdiscord_rpc, flxanimate and tjson each keep their own licenses. `libvlc` (LGPL 2.1+) and its plugins ship in the release's `vlc/` folder, unmodified, from videolan (https://www.videolan.org).
