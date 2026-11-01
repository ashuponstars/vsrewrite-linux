package backend;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.graphics.tile.FlxDrawBaseItem;

/**
 * FlxGame that survives a broken draw queue: if drawing a frame throws, say which queued item was bad,
 * drop that frame's queue and carry on, instead of closing the game.
 */
@:cppFileCode('#include <malloc.h>
#include <stdlib.h>
#include <math.h>
// keep the binary loadable on glibc < 2.38 (ubuntu 22.04, debian 12...): bind these two to their old versions
extern "C" long vsr_old_strtol(const char*, char**, int);
extern "C" double vsr_old_fmod(double, double);
__asm__(".symver vsr_old_strtol,strtol@GLIBC_2.2.5");
__asm__(".symver vsr_old_fmod,fmod@GLIBC_2.2.5");
extern "C" long __isoc23_strtol(const char* a, char** b, int c) { return vsr_old_strtol(a, b, c); }
extern "C" double fmod(double a, double b) { return vsr_old_fmod(a, b); }')
class PsychGame extends FlxGame
{
	var drawFailures:Int = 0;
	var vsrT:Float = 0;
	var vsrDone:Bool = false;

	@:access(flixel.system.frontEnds.BitmapFrontEnd)
	static function cachedGraphics():Int
	{
		var n = 0;
		for (_ in FlxG.bitmap._cache.keys()) n++;
		return n;
	}

	var trimT:Int = 0;
	var sweepT:Int = 0;
	var trimState:String = '';

	/**
	 * RAM: an image is uploaded to the GPU the first time it is drawn, and after that the game keeps a second full copy in
	 * system RAM that nothing reads (the mod never reads image pixels). Once an image's texture is up to date its RAM copy is
	 * freed. Nothing is preloaded, so video memory use is the same as before and the picture is identical. After a
	 * screen change the freed memory is also handed back to the system.
	 */
	@:access(openfl.display.BitmapData)
	function trimMemory():Void
	{
		#if (linux && cpp)
		if (ClientPrefs.data.cacheOnGPU) return;
		if (++sweepT >= 45)
		{
			sweepT = 0;
			var ctx = FlxG.stage.context3D;
			if (ctx != null)
			{
				for (k => g in Paths.currentTrackedAssets)
				{
					if (g == null) continue;
					var b = g.bitmap;
					if (b == null || !b.readable || b.image == null || b.__texture == null || b.image.version != b.__textureVersion) continue;
					if (k.indexOf('noteColorMenu') >= 0 || k.indexOf('/icons/') >= 0) continue; // the editors / options read these
					b.disposeImage();
					b.getTexture(ctx); // texture already current: this just lets go of the RAM copy
				}
			}
		}
		var st = FlxG.state == null ? '' : Type.getClassName(Type.getClass(FlxG.state));
		if (st != trimState) { trimState = st; trimT = 150; }
		if (trimT > 0 && --trimT == 0 && st != 'states.PlayState')
		{
			cpp.vm.Gc.run(true);
			cpp.vm.Gc.compact();
			untyped __cpp__('malloc_trim(0)');
		}
		#end
	}

	var memT:Float = 0;
	var lastT:Int = 0;
	var frames:Int = 0;
	var frameSum:Int = 0;
	var frameMax:Int = 0;
	var slow:Int = 0;
	var memState:String = '';

	/** Debug builds: a line in the log every 5 s and on every state change, so leaks and growth between screens show up. */
	function memLog():Void
	{
		#if (linux && vsr_debug)
		var nowT = openfl.Lib.getTimer();
		if (lastT > 0) { var d = nowT - lastT; frames++; frameSum += d; if (d > frameMax) frameMax = d; if (d > 50) slow++; }
		lastT = nowT;
		memT += FlxG.elapsed;
		var st = FlxG.state == null ? '' : Type.getClassName(Type.getClass(FlxG.state));
		if (memT < 5 && st == memState) return;
		memT = 0;
		memState = st;
		try
		{
			var rss = '?';
			for (l in sys.io.File.read('/proc/self/status').readAll().toString().split('\n'))
				if (StringTools.startsWith(l, 'VmRSS:')) { rss = StringTools.trim(l.substr(6)); break; }
			var heap = Std.int(cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_USAGE) / 1048576);
			var tracked = 0;
			for (_ in Paths.currentTrackedAssets.keys()) tracked++;
			Sys.println('[mem] rss=' + rss + ' gcheap=' + heap + 'MB images=' + tracked + ' fps=' + (frameSum > 0 ? Std.int(frames * 1000 / frameSum) : 0) + ' worstframe=' + frameMax + 'ms slowframes=' + slow + ' state=' + st);
			frames = 0; frameSum = 0; frameMax = 0; slow = 0;
		}
		catch (e:Dynamic) {}
		#end
	}

	var lastBorderless:Bool = false;

	/** The end credits turn the window borderless and fullscreen-sized; the desktop isn't visible there, so the bar goes away
	 * with it and comes back when the window gets its border again. (Trinity's own see-through part is handled separately.) */
	function followBorderless():Void
	{
		var win = lime.app.Application.current.window;
		if (win == null || win.borderless == lastBorderless) return;
		lastBorderless = win.borderless;
		if (backend.WindowTransparency.barWatching()) return;
		if (lastBorderless) backend.TaskbarHider.hide(); else backend.TaskbarHider.restore();
	}

	var sizeWrong:Float = 0;
	var sizeTries:Int = 0;

	/** Some compositors hand a window back its old size after it leaves borderless/fullscreen. In the fixed-size menus the
	 * window must match the game; if it hasn't for half a second, ask again (a few times) and recentre. */
	function fixWindowSize():Void
	{
		var win = lime.app.Application.current.window;
		if (win == null || win.borderless || win.fullscreen || !Std.isOfType(FlxG.scaleMode, flixel.system.scaleModes.StageSizeScaleMode)
			|| (win.width == FlxG.width && win.height == FlxG.height))
		{
			sizeWrong = 0;
			sizeTries = 0;
			return;
		}
		sizeWrong += FlxG.elapsed;
		if (sizeWrong < 0.5 || sizeTries >= 4) return;
		sizeWrong = 0;
		sizeTries++;
		FlxG.resizeWindow(FlxG.width, FlxG.height);
		var dm = win.display != null ? win.display.currentMode : null;
		if (dm != null) { win.x = Std.int((Math.ceil(dm.width * win.scale) - win.width) / 2); win.y = Std.int((Math.ceil(dm.height * win.scale) - win.height) / 2); }
		Sys.println('[window] size self-correct -> ' + FlxG.width + 'x' + FlxG.height);
	}

	// testing aid (VSR_LAYERED=1): after 6 s paint the key colour and switch the see-through window on, on any screen
	override function update():Void
	{
		super.update();
		backend.WindowTransparency.tick();
		fixWindowSize();
		trimMemory();
		memLog();
		followBorderless();
		#if (linux && vsr_debug)
		if (!vsrDone && backend.VsrDebug.env('VSR_LAYERED') != null)
		{
			vsrT += FlxG.elapsed;
			if (vsrT > 6 && FlxG.state != null)
			{
				vsrDone = true;
				if (backend.VsrDebug.env('VSR_LAYERED') == '2')
				{
					// two cameras: a red one underneath, and a top one that is key coloured on its left half only
					for (m in FlxG.state.members) if (m != null) m.visible = false;
					var under = new flixel.FlxCamera(0, 0, FlxG.width, FlxG.height);
					under.bgColor = 0xFFFF0000;
					FlxG.cameras.add(under, false);
					FlxG.cameras.list.remove(under);
					FlxG.cameras.list.insert(0, under);
					FlxG.game.setChildIndex(under.flashSprite, FlxG.game.getChildIndex(FlxG.camera.flashSprite));
					FlxG.camera.bgColor = 0x00000000;
					var keyHalf = new flixel.FlxSprite(0, 0); keyHalf.makeGraphic(Std.int(FlxG.width / 2), FlxG.height, 0xFF131313); keyHalf.cameras = [FlxG.camera]; FlxG.state.add(keyHalf); keyHalf.visible = true;
					FlxG.state.visible = true;
					backend.WindowTransparency.setLayered(true);
					return;
				}
				FlxG.camera.bgColor = 0xFF131313;
				FlxG.state.visible = false;
				var box = new flixel.FlxSprite(300, 250); box.makeGraphic(200, 200, 0xFFFF0000); box.cameras = [FlxG.camera]; FlxG.state.add(box); box.visible = true; FlxG.state.visible = true; for (m in FlxG.state.members) if (m != null && m != box) m.visible = false;
				backend.WindowTransparency.setLayered(true);
			}
		}
		#end
	}

	@:access(flixel.FlxCamera)
	override function draw():Void
	{
		try
		{
			super.draw();
		}
		catch (e:Dynamic)
		{
			drawFailures++;
			if (drawFailures <= 5) report(e);
			for (cam in FlxG.cameras.list) if (cam != null) cam.clearDrawStack();
			if (drawFailures > 120) throw e; // not a one-off, let the crash handler have it
		}
	}

	@:access(flixel.FlxCamera)
	function report(e:Dynamic):Void
	{
		Sys.println('[draw] frame failed: ' + Std.string(e) + '\n' + haxe.CallStack.toString(haxe.CallStack.exceptionStack()) + '\nstate=' + Type.getClassName(Type.getClass(FlxG.state)));
		for (cam in FlxG.cameras.list)
		{
			if (cam == null) continue;
			var item:FlxDrawBaseItem<Dynamic> = cam._headOfDrawStack;
			while (item != null)
			{
				Sys.println('[draw] item ' + Type.getClassName(Type.getClass(item)) + ' graphic=' + (item.graphics == null ? 'null' : item.graphics.key) + ' gshader=' + (item.graphics != null && item.graphics.shader != null));
				if (Std.isOfType(item, flixel.graphics.tile.FlxDrawQuadsItem))
				{
					var q:flixel.graphics.tile.FlxDrawQuadsItem = cast item;
					var sh:Dynamic = q.shader;
					Sys.println('[draw]   item shader=' + (sh == null ? 'null' : Type.getClassName(Type.getClass(sh)) + ' hasBitmap=' + (sh.bitmap != null)));
				}
				if (item.graphics != null)
				{
					var gs:Dynamic = item.graphics.shader;
					Sys.println('[draw]   graphic shader bitmap=' + (gs != null && gs.bitmap != null));
					if (gs == null || gs.bitmap == null) // give the image a fresh, working shader
						Reflect.setProperty(item.graphics, 'shader', new flixel.system.FlxAssets.FlxShader());
				}
				if (item.graphics == null || item.graphics.bitmap == null)
					Sys.println('[draw] bad item on camera ' + Type.getClassName(Type.getClass(cam)) + ': graphic=' + (item.graphics == null ? 'null' : item.graphics.key));
				item = item.next;
			}
		}
	}

	static function scanSprites(g:flixel.group.FlxGroup.FlxTypedGroup<Dynamic>, key:String):Void
	{
		for (m in g.members)
		{
			if (m == null) continue;
			if (Std.isOfType(m, flixel.FlxSprite))
			{
				var spr:flixel.FlxSprite = cast m;
				if (spr.graphic != null && spr.graphic.key == key && spr.visible && spr.exists)
				{
					var sh:Dynamic = spr.shader;
					Sys.println('[draw]   sprite ' + Type.getClassName(Type.getClass(spr)) + ' shader=' + (sh == null ? 'null' : Type.getClassName(Type.getClass(sh))) + ' cams=' + (spr.cameras == null ? 'null' : '' + spr.cameras.length) + ' alpha=' + spr.alpha + ' size=' + spr.width + 'x' + spr.height);
				}
			}
			if (Std.isOfType(m, flixel.group.FlxGroup.FlxTypedGroup)) scanSprites(cast m, key);
			else if (Std.isOfType(m, flixel.group.FlxSpriteGroup)) scanSprites(cast (cast m : flixel.group.FlxSpriteGroup).group, key);
		}
	}
}
