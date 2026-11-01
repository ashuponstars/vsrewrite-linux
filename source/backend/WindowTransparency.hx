package backend;

import flixel.FlxG;
import openfl.Lib;
import openfl.display.Shader;
import openfl.filters.ShaderFilter;

/**
 * Linux stand-in for the Windows "layered window with a colour key" trick the mod uses for the
 * see-through desktop sections: while on, the stage clears to alpha 0 and a final pass turns the
 * key colour (0x131313 in the mod) into alpha 0, so a compositor shows the desktop through it.
 */
class WindowTransparency
{
	public static var layered(default, null):Bool = false;

	static var key:Int = 0x131313;
	static var shader:ColorKeyShader;
	static var filter:ShaderFilter;

	public static function setKey(k:Int):Void
	{
		key = k & 0xFFFFFF;
		if (shader != null) updateKey();
	}

	static var wanted:Bool = false;
	static var pending:Bool = false;
	static var probeAdded:Bool = false;
	/** window.opacity as the mod last set it (lime stores it here on Linux, since compositors often ignore the X11 hint). */
	public static var opacity:Float = 1;
	static var appliedOpacity:Float = 1;
	static var filtersSet:Bool = false;
	static var lastCams:Array<flixel.FlxCamera> = [];
	static var barWatch:Bool = false;
	static var lastSee:Bool = false;
	static var agree:Int = 0;
	public static function barWatching():Bool return barWatch;
	public static function watchBar(on:Bool):Void { barWatch = on; agree = 0; lastSee = false; }
	static var probeCount:Int = 0;
	static var probeFrames:Int = 0;

	/** The mod flips this on and off several times per step; only the state at the end of the frame is applied. */
	public static function setLayered(on:Bool):Void
	{
		wanted = on;
		if (pending) return;
		pending = true;
		FlxG.signals.preUpdate.addOnce(apply);
	}

	static function apply():Void
	{
		pending = false;
		var on = wanted;
		if (on == layered) return;
		layered = on;
		var stage = Lib.current.stage;
		if (on)
		{
			if (shader == null)
			{
				shader = new ColorKeyShader();
				filter = new ShaderFilter(shader);
			}
			updateKey();
			stage.color = null; // clear the window to alpha 0 instead of opaque black
			try
			{
				var gl = lime.app.Application.current.window.context.gl;
				trace('transparent window on: framebuffer alpha bits=' + gl.getParameter(gl.ALPHA_BITS) + ' (needs 8 to see through)');
			}
			catch (e:Dynamic) trace('transparent window on: could not read alpha bits');
			if (!probeAdded)
			{
				probeAdded = true;
				lime.app.Application.current.window.onRender.add(probe, false, -100);
			}
			probeCount = 0;
			probeFrames = 0;
			watchFrames = 0;
		}
		else
		{
			stage.color = opacity < 1 ? null : 0x000000;
		}
	}

	/**
	 * The Windows layered window keys the FINAL picture: a key coloured pixel on a top camera hides everything below it
	 * and then turns see-through. Keying each camera alone would let the cameras below shine through, so while layered all
	 * camera sprites sit in one holder and the key pass runs once over the holder.
	 */
	static var holder:openfl.display.Sprite;

	@:access(flixel.FlxCamera)
	@:access(flixel.FlxGame)
	public static function tick():Void
	{
		if (opacity != appliedOpacity)
		{
			appliedOpacity = opacity;
			FlxG.game.alpha = opacity;
			FlxG.stage.color = (opacity < 1 || layered) ? null : 0x000000;
			Sys.println('[window] opacity ' + opacity);
		}
		if (filter == null) return;
		if (!layered)
		{
			if (holder != null && holder.parent != null) release();
			return;
		}
		// nothing changed since last frame: the camera sprites are all still in the holder, in order, with the filter on
		var list = FlxG.cameras.list;
		if (holder != null && holder.parent != null && filtersSet && list.length == lastCams.length)
		{
			var same = true;
			for (k in 0...list.length)
			{
				var c = list[k];
				if (c != lastCams[k] || (c != null && c.flashSprite != null && c.flashSprite.parent != holder)) { same = false; break; }
			}
			if (same) return;
		}
		var game:openfl.display.Sprite = FlxG.game;
		if (holder == null) holder = new openfl.display.Sprite();
		if (holder.parent == null)
		{
			var idx = game.getChildIndex(FlxG.game._inputContainer);
			if (FlxG.cameras.list.length > 0 && FlxG.cameras.list[0] != null && FlxG.cameras.list[0].flashSprite.parent == game)
				idx = game.getChildIndex(FlxG.cameras.list[0].flashSprite);
			game.addChildAt(holder, idx);
		}
		var i = 0;
		for (cam in FlxG.cameras.list)
		{
			if (cam == null || cam.flashSprite == null) continue;
			if (cam.flashSprite.parent != holder || holder.getChildIndex(cam.flashSprite) != i)
				holder.addChildAt(cam.flashSprite, Std.int(Math.min(i, holder.numChildren)));
			i++;
		}
		// cameras the mod removed while layered
		var n = holder.numChildren;
		while (n > i) { holder.removeChildAt(n - 1); n--; }
		holder.filters = [filter];
		filtersSet = true;
		lastCams = list.copy();
	}

	/** Puts the camera sprites back where flixel expects them. */
	@:access(flixel.FlxCamera)
	static function release():Void
	{
		var game:openfl.display.Sprite = FlxG.game;
		var idx = game.getChildIndex(holder);
		holder.filters = [];
		filtersSet = false;
		lastCams = [];
		var k = 0;
		for (cam in FlxG.cameras.list)
		{
			if (cam == null || cam.flashSprite == null) continue;
			game.addChildAt(cam.flashSprite, Std.int(Math.min(idx + 1 + k, game.numChildren)));
			k++;
		}
		game.removeChild(holder);
	}

	/** Diagnostic: after the stage has drawn, read back a few pixels of the window so the log shows what is really on screen. */
	static var watchFrames:Int = 0;
	static function probe(ctx:lime.graphics.RenderContext):Void
	{
		// the desktop bar follows the desktop: it is shown while any sampled point of the window is see-through
		// and hidden while the window is solid (two matching samples in a row, so a single flash can't toggle it).
		// Only runs while a song has asked for it (Trinity's fullscreen part), a handful of 1-pixel reads per second.
		if (barWatch && !layered) TaskbarHider.hide(); // solid window: the desktop isn't visible
		else if (barWatch && ++watchFrames % 6 == 0)
		{
			try
			{
				var gl = ctx.gl;
				var w = lime.app.Application.current.window.width;
				var h = lime.app.Application.current.window.height;
				var b = new lime.utils.UInt8Array(4);
				var see = false;
				for (pt in [[4, 4], [w - 4, 4], [4, h - 4], [w - 4, h - 4], [Std.int(w / 2), Std.int(h / 2)]])
				{
					gl.readPixels(pt[0], pt[1], 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, b);
					if (b[3] == 0) { see = true; break; }
				}
				if (see == lastSee) { if (agree < 2) agree++; } else { lastSee = see; agree = 1; }
				if (agree == 2)
				{
					if (see) TaskbarHider.restore(); else TaskbarHider.hide();
				}
			}
			catch (e:Dynamic) {}
		}
		if (!VsrDebug.ON || !layered || probeCount >= 6) return;
		probeFrames++;
		if (probeFrames % 120 != 30) return;
		probeCount++;
		try
		{
			var gl = ctx.gl;
			var w = lime.app.Application.current.window.width;
			var h = lime.app.Application.current.window.height;
			var out = '';
			for (pt in [[4, 4], [Std.int(w / 2), Std.int(h / 2)], [w - 4, h - 4]])
			{
				var buf = new lime.utils.UInt8Array(4);
				gl.readPixels(pt[0], pt[1], 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, buf);
				out += ' (' + pt[0] + ',' + pt[1] + ')=' + buf[0] + ',' + buf[1] + ',' + buf[2] + ',' + buf[3];
			}
			trace('transparent window pixels rgba:' + out + ' window ' + w + 'x' + h);
		}
		catch (e:Dynamic) trace('transparent window probe failed: ' + e);
	}

	static function updateKey():Void
	{
		shader.data.uKey.value = [((key >> 16) & 0xFF) / 255, ((key >> 8) & 0xFF) / 255, (key & 0xFF) / 255];
	}
}

class ColorKeyShader extends flixel.system.FlxAssets.FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform vec3 uKey;
		const vec3 kKey = vec3(0.07451);
		void main()
		{
			vec4 c = texture2D(bitmap, openfl_TextureCoordv);
			vec3 d = abs(c.rgb - (uKey.x + uKey.y + uKey.z > 0.0 ? uKey : kKey));
			if (c.a < 0.01 || max(d.r, max(d.g, d.b)) < 0.025) gl_FragColor = vec4(0.0);
			else gl_FragColor = vec4(c.rgb, 1.0);
		}
	')
	public function new()
	{
		super();
	}
}
