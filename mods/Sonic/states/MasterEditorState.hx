import flixel.addons.transition.FlxTransitionableState;
import backend.Discord;
import backend.MusicBeatState;
import flixel.text.FlxText;
import states.LoadingState;
import objects.Character;
import states.editors.ChartingState;
import states.editors.CharacterEditorState;
import states.editors.NoteSplashDebugState;
import openfl.Lib;

var debug:FlxSprite;
var curSelected:Int = 0;
var options:Array = ["CHARACTER EDITOR", "CHART EDITOR", "NOTE SPLASH EDITOR", "PLAY POST CREDITS", "RESET MAIGO PROGRESSION", "RESET SONG PROGRESSION", "RESET CREDITS PROGRESSION", "TEST STATE"];
var optionButtons:Array = [];
var leaving:Bool = false;

function onCreate()
{
    DiscordClient.changePresence("Master Editor Menu", null);

    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;
    resizeWindow(820, 720);

    debug = new FlxSprite().loadGraphic(Paths.image("menus/debug"));
    debug.scale.set(2, 2);
    debug.screenCenter();
    game.add(debug);

    for (i in 0...options.length) {
        var menuText = new FlxText(0, -50, FlxG.width, options[i]);
        menuText.setFormat(Paths.font("sonic2HUD.ttf"), 55, 0xFFFFFFFF, "center", FlxTextBorderStyle.SHADOW, 0xFF000000);
        menuText.shadowOffset.x += 1;
        menuText.shadowOffset.y += 3;
        menuText.screenCenter();
        menuText.y += i * 70 - 200;
        optionButtons.push(menuText);
        game.add(menuText);
    }

    changeSelection(0, true);
}

function changeSelection(change:Int = 0, silent:Bool = false)
{
    if (!silent) FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);

    curSelected += change;
    if (curSelected > optionButtons.length - 1) curSelected = 0;
    if (curSelected < 0) curSelected = optionButtons.length - 1;

    for (i in 0...optionButtons.length) {
        if (i == curSelected) {
            optionButtons[i].color = 0xFFFCFC00;
        } else {
            optionButtons[i].color = 0xFFFFFFFF;
        }
    }
}

function onUpdate(e)
{
    if (leaving) return;

    if (controls.BACK) {
        leaving = true;
        MusicBeatState.switchState(new CustomState(), Paths.hscript("states/MainMenuState"));
    }

    if (controls.UI_UP_P || controls.UI_DOWN_P) changeSelection(controls.UI_UP_P ? -1 : 1, false);
    if (controls.ACCEPT) {
        leaving = true;

        if (options[curSelected] == "CHARACTER EDITOR" || options[curSelected] == "CHART EDITOR" || options[curSelected] == "NOTE SPLASH EDITOR") resizeWindow(1280, 720);
        switch (options[curSelected])
        {
            case "CHARACTER EDITOR": LoadingState.loadAndSwitchState(new CharacterEditorState(Character.DEFAULT_CHARACTER, false));
            case "CHART EDITOR": LoadingState.loadAndSwitchState(new ChartingState(), false);
            case "NOTE SPLASH EDITOR": MusicBeatState.switchState(new NoteSplashDebugState());
            case "PLAY POST CREDITS": 
                resizeWindow(1280, 720);
                MusicBeatState.switchState(new CustomState(), Paths.hscript("states/PostCreditsState"));
            case "TEST STATE": MusicBeatState.switchState(new CustomState(), Paths.hscript("states/TestState"));
            case "RESET MAIGO PROGRESSION":
                FlxG.save.data.seenMaigoDialogues = [];
                FlxG.save.data.seenMaigoIntroduction = false;
                FlxG.save.flush();
                leaving = false;
                FlxG.sound.play(Paths.sound("windowsShutdown"));

            case "RESET SONG PROGRESSION":
                FlxG.save.data.beatenTG = false;
                FlxG.save.data.beatenTrinity = false;
                FlxG.save.flush();
                leaving = false;
                FlxG.sound.play(Paths.sound("confirmLaugh"));

            case "RESET CREDITS PROGRESSION":
                FlxG.save.data.seenLegacySplash = false;
                FlxG.save.data.seenCreditsRoll = false;
                FlxG.save.data.seenPostCredits = false;
                FlxG.save.flush();
                leaving = false;
                FlxG.sound.play(Paths.sound("deathHit"));

            case "TEST STATE": MusicBeatState.switchState(new CustomState(), Paths.hscript("states/TestState"));
        }
    }
}

function resizeWindow(width:Int, height:Int)
{
    FlxG.resizeGame(width, height);
    FlxG.resizeWindow(width, height);
    var resolutionX = Math.ceil(Lib.current.stage.window.display.currentMode.width * Lib.current.stage.window.scale);
    var resolutionY = Math.ceil(Lib.current.stage.window.display.currentMode.height * Lib.current.stage.window.scale);
    Lib.application.window.x = (resolutionX - Lib.application.window.width) / 2;
    Lib.application.window.y = (resolutionY - Lib.application.window.height) / 2;
}

function onDestroy() {}