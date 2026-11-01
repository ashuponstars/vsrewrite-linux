# what's different from psych engine 0.7.3

short version: 17 upstream files changed, 6 files added, assets and art untouched. the full diff is in [changes-vs-upstream.diff](changes-vs-upstream.diff).

## new files

| file | what it is |
|---|---|
| `source/backend/PsychGame.hx` | our `FlxGame`. a frame that fails to draw is dropped and logged instead of crashing the game. each frame it also runs the see-through window pass, fixes the window size if the compositor handed back the wrong one, hides the desktop bar while the window is borderless (end credits), and frees the extra ram copy of images once they're on the gpu |
| `source/backend/WindowTransparency.hx` | the see-through window. windows does this with a colour key on a layered window, here the window has real alpha and a shader turns the key colour (`0x131313`) transparent once, over all cameras together. also stores `window.opacity` and fades the picture with it, and watches the window so the desktop bar follows the desktop |
| `source/backend/TaskbarHider.hx` | runs `hide-bar.sh` / `restore-bar.sh` when the bar should hide or come back, plus the optional `coverBar` hyprland fullscreen trick |
| `source/backend/VsrDebug.hx` | the switch between debug and release (`-Dvsr_debug`) |
| `source/states/CustomState.hx` | an engine state that runs the mod's hscript menus (`mods/Sonic/states/*.hx`). in debug builds it also reads the `VSR_*` test variables |
| `source/objects/MaigoSpeaker.hx` | an object the mod's scripts use |

## changed files

- `Project.xml`: window is 820x720 and not resizable, videos are allowed in non-official builds, `hxvlc` instead of `hxCodec`
- `Main.hx`: starts in `CustomState`, uses `PsychGame`, makes the fps counter before the game so menu scripts can use it
- `states/PlayState.hx`: `getStageSizeScaleMode` / `getRatioScaleMode` for the mod's scripts, the `camFX` and `camVideo` cameras, window set back to the song layout on restart or retry (the menu normally does it and a restart skips the menu), the trinity bar hiding steps, and the debug hooks
- `psychlua/FunkinLua.hx`: new lua values (`checkpointTime`, `windowFuckery`, `windowClosing`, `songVariation`), new functions (`loadScript`, `makeLuaBackdrop`, `addLuaBackdrop`), and a stand-in for the mod's windows-only `ffi` calls: on linux the lua transparency script's calls are answered by the engine and the real work is done by `WindowTransparency`
- `psychlua/LuaUtils.hx`: `fx` and `video` camera names. `psychlua/TextFunctions.hx`: `getTextHeight`
- `backend/ClientPrefs.hx`: `windowFuckery`, `windowClosing`, `coverBar`, `remixedLegacySongs`
- `backend/Paths.hx`: `clearImageFromMemory`
- `backend/MusicBeatState.hx`: `switchState` can take a script path
- `backend/Discord.hx`: `getPresence`. `debug/FPSCounter.hx`: `defaultColor`
- `options/ControlsSubState.hx`, `options/OptionsState.hx`: controls is a state now and goes back through the mod's options script
- `substates/GameOverSubstate.hx`, `substates/PauseSubState.hx`: leaving a song goes to the mod's main menu instead of story / freeplay

## library patches

- flixel 5.5.0: `FlxDrawQuadsItem.render` skips an item whose image is gone instead of throwing for the whole frame
- lime 8.1.2: on linux `window.opacity` is stored by the game instead of being sent to sdl (compositors often ignore the x11 opacity hint)

## the ARGB shim

`argb/vsr_argb.c`, see [BUILDING.md](../BUILDING.md). sdl's default x visual is 24-bit with no alpha, so the compositor can't see through the window. this makes sdl choose a 32-bit visual.

## things the engine does that are specific to the mod's trinity chart

the step numbers for hiding the bar (3596) come from the mod's chart. other songs are not affected.
