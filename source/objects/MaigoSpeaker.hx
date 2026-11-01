package objects;

import flixel.group.FlxSpriteGroup;
import flixel.addons.text.FlxTypeText;
import flixel.sound.FlxSound;

/**
 * Maigo's dialogue box (gallery, music player, computer): a dark backing, a face icon, and
 * typed text that is spoken by a voice clip.
 *
 * A dialogue line is [text, emote, voiceKey, typeDelay, holdSeconds, fontSize]:
 *   emote       animation name on the icon (or on `emoteOutput`)
 *   voiceKey    clip under sounds/maigo/ (e.g. "musicPlayer/3")
 *   typeDelay   seconds per typed character
 *   holdSeconds pause after the voice clip ends before the next line (inferred, see docs)
 *   fontSize    text size, smaller for longer lines (optional, default 39)
 */
class MaigoSpeaker extends FlxSpriteGroup
{
	public var backing:FlxSprite;
	public var icon:FlxSprite;
	public var text:FlxTypeText;
	public var voiceline:FlxSound;
	public var emoteOutput:FlxSprite;
	public var currentlySpeaking:Bool = false;
	public var currentDialogueArray:Array<Dynamic> = [];
	public var resetTimer:FlxTimer;

	/** called when a line begins, with the line array */
	public dynamic function onStartDialogue(line:Array<Dynamic>):Void {}

	/** called when the last line has finished */
	public dynamic function onEndReached():Void {}

	public static inline var DEFAULT_SIZE:Int = 39;
	static inline var BOX_HEIGHT:Int = 170;

	var iconVisible:Bool = true;

	public function new()
	{
		super();
		scrollFactor.set();

		var top:Float = FlxG.height - BOX_HEIGHT;

		backing = new FlxSprite(0, top).makeGraphic(FlxG.width, BOX_HEIGHT, 0xFF000000);
		backing.alpha = 0.001;
		add(backing);

		icon = new FlxSprite(70, top + 44);
		icon.frames = Paths.getSparrowAtlas('menus/gallery/maigo/talk');
		for (anim in ['talk', 'hype', 'eyesClosed', 'embarrassed'])
			icon.animation.addByPrefix(anim, anim, 15, true);
		icon.animation.play('talk');
		icon.antialiasing = false;
		icon.alpha = 0.001;
		add(icon);

		text = new FlxTypeText(258, top + 20, 580, '', DEFAULT_SIZE);
		text.setFormat(Paths.font('sonic2HUD.ttf'), DEFAULT_SIZE, 0xFFFFFFFF, LEFT);
		add(text);

		emoteOutput = icon;
		swapSpeaker(true);
	}

	/** true: face icon at the left with the text beside it; false: no icon, text across the box */
	public function swapSpeaker(showIcon:Bool):Void
	{
		iconVisible = showIcon;
		if (showIcon)
		{
			icon.x = 70;
			text.x = 258;
			text.fieldWidth = 580;
		}
		else
		{
			text.x = 0;
			text.fieldWidth = FlxG.width;
		}
		if (!currentlySpeaking) icon.alpha = 0.001;
	}

	public function startDialogue(lines:Array<Dynamic>):Void
	{
		currentDialogueArray = lines.copy();
		currentlySpeaking = true;
		backing.alpha = 0.5;
		nextDialogue();
	}

	public function nextDialogue():Void
	{
		if (resetTimer != null) resetTimer.cancel();

		if (currentDialogueArray.length == 0)
		{
			currentlySpeaking = false;
			backing.alpha = 0.001;
			icon.alpha = 0.001;
			text.resetText('');
			onEndReached();
			return;
		}

		var line:Array<Dynamic> = currentDialogueArray.shift();
		var size:Int = line.length > 5 && line[5] != null ? Std.int(line[5]) : DEFAULT_SIZE;
		var delay:Float = line.length > 3 && line[3] != null ? line[3] : 0.05;
		var hold:Float = line.length > 4 && line[4] != null ? line[4] : 1.0;

		onStartDialogue(line);

		if (emoteOutput != null)
		{
			emoteOutput.alpha = 1;
			if (emoteOutput.animation.exists(line[1])) emoteOutput.animation.play(line[1], true);
		}
		if (iconVisible) icon.alpha = 1;

		text.size = size;
		text.resetText(line[0]);
		text.start(delay, true, false, null, null);

		if (voiceline != null) voiceline.stop();
		voiceline = FlxG.sound.play(Paths.sound('maigo/' + line[2]));
		voiceline.onComplete = function()
		{
			resetTimer = new FlxTimer().start(hold, function(_) nextDialogue());
		};
	}

	override function destroy():Void
	{
		if (resetTimer != null) resetTimer.cancel();
		if (voiceline != null) { voiceline.onComplete = null; voiceline.stop(); }
		super.destroy();
	}
}
