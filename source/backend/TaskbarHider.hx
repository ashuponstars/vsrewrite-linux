package backend;

/**
 * "Hide Taskbar" / "Restore Taskbar" chart events (not used any more: Trinity hides the bar by step instead, see PlayState.stepHit). On Windows the original hides
 * the taskbar. Here the bar is whatever panel the desktop has. With "Taskbar Hiding" on, two small shell scripts
 * next to the game, which the player writes for their own bar, are run:
 *   hide-bar.sh     run when the taskbar should go away
 *   restore-bar.sh  run when it should come back
 * Without those scripts, Hyprland falls back to putting the game window in compositor fullscreen, which covers
 * layer-shell bars, and back again.
 */
class TaskbarHider
{
	static var hidden:Bool = false;
	static var covered:Bool = false;

	public static function hide():Void
	{
		if (hidden) return;
		hidden = true;
		#if vsr_debug
		Sys.println('[bar] HIDE');
		#end
		// "Taskbar Hiding": the player's own script knows how to hide their bar
		if (ClientPrefs.data.windowClosing) runScript('hide-bar.sh');
		// "Cover Bar": Hyprland shows the game window above layer-shell bars while it is in compositor fullscreen
		if (ClientPrefs.data.coverBar) { covered = true; hypr(['dispatch', 'fullscreenstate', '2', '0']); }
	}

	public static function restore():Void
	{
		if (!hidden) return;
		hidden = false;
		#if vsr_debug
		Sys.println('[bar] RESTORE');
		#end
		if (ClientPrefs.data.windowClosing) runScript('restore-bar.sh');
		if (covered) { covered = false; hypr(['dispatch', 'fullscreenstate', '0', '0']); }
	}

	static function runScript(script:String):Void
	{
		#if (linux || mac)
		try
		{
			if (sys.FileSystem.exists(script)) new sys.io.Process('/bin/sh', [script]);
			else if (sys.FileSystem.exists('bar-auto.sh')) new sys.io.Process('/bin/sh', ['bar-auto.sh', script == 'hide-bar.sh' ? 'hide' : 'restore']);
		}
		catch (e:Dynamic) trace('taskbar: ' + e);
		#end
	}

	static function hypr(args:Array<String>):Void
	{
		#if (linux || mac)
		try { if (Sys.getEnv('HYPRLAND_INSTANCE_SIGNATURE') != null) new sys.io.Process('hyprctl', args); }
		catch (e:Dynamic) trace('hyprctl: ' + e);
		#end
	}
}
