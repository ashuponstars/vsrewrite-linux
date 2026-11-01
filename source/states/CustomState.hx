package states;

import tea.SScript;
import backend.Highscore;
import backend.Discord.DiscordClient;
import flixel.addons.transition.FlxTransitionableState;
import psychlua.HScript.CustomFlxColor;

/**
 * Host for the menu / screen scripts in mods/<mod>/states/*.hx.
 *
 * The script is a plain SScript with this state as its "special object", so
 * unqualified names in the script (add, controls, persistentUpdate ...) resolve
 * against the state. `game` is also exposed as an alias for the state.
 * Callbacks looked up on the script: onCreate, onCreatePost, onUpdate, onUpdatePost,
 * onStepHit, onBeatHit, onSectionHit, onDestroy.
 */
class CustomState extends MusicBeatState
{
	/** shared flag the scripts use to remember which menu page (data / main) to open */
	public static var dataSelect:Bool = false;

	/** script opened when the game boots (resolved through Paths.hscript) */
	public static var initialScript:String = 'states/TitleState';

	static var bootstrapped:Bool = false;

	public var script:SScript;
	public var scriptPath:String;
	public var game:CustomState;

	public function new(?scriptPath:String)
	{
		super();
		this.scriptPath = scriptPath;
	}

	override function create()
	{
		if (!bootstrapped)
		{
			// what the stock TitleState does on boot, because the script screens do not
			bootstrapped = true;
			FlxG.save.bind('funkin', CoolUtil.getSavePath());
			Mods.pushGlobalMods();
			Mods.loadTopMod();
			backend.ClientPrefs.loadPrefs();
			Highscore.load();
			FlxTransitionableState.skipNextTransOut = true; // no fade-in on boot (it would be wiped by the script's memory clear)
		}

		if (scriptPath == null)
		{
			// VSR_SCRIPT=states/MainMenuState starts on that screen (testing aid)
			var forced:String = backend.VsrDebug.env('VSR_SCRIPT');
			scriptPath = Paths.hscript((forced != null && forced != '') ? forced : initialScript);
		}

		persistentUpdate = persistentDraw = true;
		game = this;
		super.create();

		loadScript();
		callScript('onCreate');
		callScript('onCreatePost');

		if (backend.VsrDebug.env('VSR_LAYERED') != null) new FlxTimer().start(3, function(_) { FlxG.camera.bgColor = 0xFF131313; for (o in FlxG.state.members) if (o != null) o.visible = false; backend.WindowTransparency.setLayered(true); }); // testing aid only
		if (backend.VsrDebug.env('VSR_CONTROLS') != null) new FlxTimer().start(2, function(_) MusicBeatState.switchState(new options.ControlsSubState())); // testing aid only
		// testing aid: VSR_SONG="Trinity" jumps straight into that song, like the main menu does
		var song:String = backend.VsrDebug.env('VSR_SONG');
		if (song != null && song != '')
		{
			new FlxTimer().start(1, function(_)
			{
				if (FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
				if (backend.VsrDebug.env('VSR_BOT') != null) ClientPrefs.data.gameplaySettings.set('botplay', true); // testing aid only
				if (backend.VsrDebug.env('VSR_RATE') != null) ClientPrefs.data.gameplaySettings.set('songspeed', Std.parseFloat(backend.VsrDebug.env('VSR_RATE'))); // testing aid: play faster
				// testing aid: VSR_FF="3,3490" plays at 3x with botplay until step 3490, then hands over at normal speed
				if (backend.VsrDebug.env('VSR_FF') != null) { var ff = backend.VsrDebug.env('VSR_FF').split(','); ClientPrefs.data.gameplaySettings.set('botplay', true); ClientPrefs.data.gameplaySettings.set('songspeed', Std.parseFloat(ff[0])); }
				PlayState.SONG = backend.Song.loadFromJson(song, song);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = 0;
				PlayState.songVariation = null;
				PlayState.checkpointTime = 0;
				FlxG.resizeWindow(1280, 720);
				FlxG.resizeGame(1280, 720);
				states.LoadingState.loadAndSwitchState(new PlayState());
			});
		}
	}

	function loadScript()
	{
		if (!sys.FileSystem.exists(scriptPath))
		{
			trace('CustomState: script not found: $scriptPath');
			return;
		}

		script = new SScript('', false, false);
		script.traces = true;
		script.debugTraces = true;
		script.preset();

		script.set('game', this);
		// scripts assign these, and the special object only resolves reads
		script.set('persistentUpdate', true);
		script.set('persistentDraw', true);
		script.set('FlxG', FlxG);
		script.set('FlxSprite', FlxSprite);
		script.set('FlxText', flixel.text.FlxText);
		script.set('FlxTween', flixel.tweens.FlxTween);
		script.set('FlxEase', flixel.tweens.FlxEase);
		script.set('FlxTimer', flixel.util.FlxTimer);
		script.set('FlxMath', flixel.math.FlxMath);
		script.set('FlxCamera', flixel.FlxCamera);
		script.set('FlxColor', CustomFlxColor);
		script.set('FlxSound', flixel.sound.FlxSound);
		script.set('FlxBackdrop', flixel.addons.display.FlxBackdrop);
		script.set('FlxTransitionableState', FlxTransitionableState);
		script.set('Paths', Paths);
		script.set('Conductor', Conductor);
		script.set('ClientPrefs', backend.ClientPrefs);
		script.set('CoolUtil', CoolUtil);
		script.set('Mods', Mods);
		script.set('Highscore', Highscore);
		script.set('Song', backend.Song);
		script.set('Alphabet', Alphabet);
		script.set('Controls', backend.Controls);
		script.set('MusicBeatState', MusicBeatState);
		script.set('CustomState', CustomState);
		script.set('PlayState', PlayState);
		script.set('DiscordClient', DiscordClient);
		script.set('Main', Main);
		script.set('Lib', openfl.Lib);

		script.set('MaigoSpeaker', objects.MaigoSpeaker);
		#if VIDEOS_ALLOWED
		script.set('FlxVideoSprite', hxvlc.flixel.FlxVideoSprite);
		#end
		script.setSpecialObject(this);
		// same line as the script's first line, so error line numbers stay correct
		script.doString('import flixel.text.FlxTextBorderStyle; ' + sys.io.File.getContent(scriptPath), scriptPath);

		if (script.parsingException != null)
			trace('CustomState: error in $scriptPath: ' + script.parsingException.message);
	}

	public function callScript(func:String, ?args:Array<Dynamic>):Dynamic
	{
		if (script == null || !script.exists(func)) return null;
		var res = script.call(func, args == null ? [] : args);
		if (res.exceptions != null && res.exceptions.length > 0)
			for (e in res.exceptions) trace('CustomState: $func in $scriptPath: ' + e.message);
		return res.returnValue;
	}

	override function update(elapsed:Float)
	{
		callScript('onUpdate', [elapsed]);
		super.update(elapsed);
		callScript('onUpdatePost', [elapsed]);
	}

	override function stepHit()
	{
		super.stepHit();
		callScript('onStepHit');
	}

	override function beatHit()
	{
		super.beatHit();
		callScript('onBeatHit');
	}

	override function sectionHit()
	{
		super.sectionHit();
		callScript('onSectionHit');
	}

	override function destroy()
	{
		callScript('onDestroy');
		if (script != null)
		{
			script.destroy();
			script = null;
		}
		super.destroy();
	}
}
