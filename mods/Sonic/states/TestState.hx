import flixel.addons.transition.FlxTransitionableState;
import backend.MusicBeatState;

var leaving:Bool = false;
var testImage:FlxSprite;

function onCreate()
{
    if (FlxG.sound.music != null) FlxG.sound.music.stop();

    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;

    var bg = new FlxSprite().makeGraphic(300, 300, 0xFFFFFFFF);
    bg.scale.set(3.3, 3.3);
    bg.screenCenter();
    game.add(bg);

    testImage = new FlxSprite().loadGraphic(Paths.image("blueCloudsScary"));
    testImage.screenCenter();
    game.add(testImage);
}

function onUpdate(e)
{
    if (leaving) return;

    if (FlxG.keys.justPressed.F) {
        testImage.destroy();
        Paths.clearImageFromMemory("blueCloudsScary.png");
    }

    if (controls.BACK) {
        leaving = true;
        MusicBeatState.switchState(new CustomState(), Paths.hscript("states/MainMenuState"));
    }
}