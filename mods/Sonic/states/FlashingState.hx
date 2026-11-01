import flixel.addons.transition.FlxTransitionableState;
import states.FlashingState;
import backend.Discord;

var bg:FlxSprite;
var warning:FlxSprite;
var text:FlxSprite;
var accepted:Bool = false;
var warningSound:FlxSound;

function onCreate()
{
    DiscordClient.changePresence("Flashing Lights Disclaimer", null);
    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;

    bg = new FlxSprite().loadGraphic(Paths.image("menus/warning"));
    bg.scale.set(2, 2);
    bg.screenCenter();
    bg.alpha = 0;
    bg.color = 0xFF0000FF;
    game.add(bg);

    warningSound = FlxG.sound.load(Paths.sound("warning"));

    new FlxTimer().start(0.5, function(tmr) {

        FlxTween.color(bg, 0.3, 0xFF0000FF, 0xFFFFFFFF);
        FlxTween.tween(bg, {alpha: 1}, 0.5);
        FlxG.sound.play(Paths.sound("selectSong"));

        new FlxTimer().start(0.75, function(tmr) {
            warningSound.play();
        });
    });
}

function onUpdate()
{
    if (controls.ACCEPT && !accepted)
    {
        FlxG.sound.play(Paths.sound("confirmMenu"));
        accepted = true;
        FlxTween.color(bg, 0.3, 0xFFFFFFFF, 0xFF0000FF);
        FlxG.camera.fade(0xFF000000, 0.5);
        warningSound.fadeOut(0.3, 0);
        new FlxTimer().start(0.55, function(tmr) {
            FlashingState.leftState = true;
            MusicBeatState.switchState(new CustomState(), Paths.hscript("states/TitleState"));
        });
    }
}

function onDestroy() {}