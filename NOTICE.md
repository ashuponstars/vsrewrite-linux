# notice

this project is a fork of **psych engine 0.7.3** (https://github.com/ShadowMario/FNF-PsychEngine), licensed under the apache license 2.0 (see `LICENSE`). psych engine is by shadowmario and the psych engine team. files in this repo that came from psych engine keep their original license. our changes are listed in `docs/CHANGES.md` and the full diff is in `docs/changes-vs-upstream.diff`.

## not included

the vs rewrite mod (scripts, art, music, charts, everything in `mods/Sonic`) is **not** part of this repo and not covered by its license. it belongs to its creators. this project is a linux build of the engine it runs on and isn't affiliated with the mod or its team.

engine assets (`assets/`, `art/`) aren't in the source repo either, `scripts/setup.sh` fetches them from upstream. the release tarball includes upstream's assets unchanged.

## libraries

haxe, lime, openfl, flixel, flixel-addons, flixel-ui, hxcpp, SScript, hxvlc, linc_luajit, hxdiscord_rpc, flxanimate and tjson each keep their own licenses. `libvlc` is used at runtime and is not bundled.
