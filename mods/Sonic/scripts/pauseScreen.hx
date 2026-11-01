import backend.MusicBeatState;
import psychlua.CustomSubstate;
import states.CustomState;
import substates.PauseSubState;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;

var overlay:FlxSprite;
var pause:FlxSprite;
var menuItems:Array = [["RESUME", []], ["RESTART", []], ["EXIT", []]];
var curSelected:Int = 0;
var selectedSomething:Bool = false;
var thisCanOpen:Bool = false; // dont even know

using StringTools;

function onCreatePost()
{
    overlay = new FlxSprite().makeGraphic(100, 100, 0xFF000000);
    overlay.scale.set(1000, 1000);
    overlay.alpha = 0.6;

    pause = new FlxSprite(605, 150);
    pause.frames = Paths.getSparrowAtlas("menus/pause/paused");
    pause.animation.addByPrefix("pause", "paused", 24, false);
    pause.animation.play("pause", true, true);
    pause.scale.set(3, 3);

    for (i in [overlay, pause]) i.cameras = [game.camOther];

    for (i in 0...menuItems.length) {
        var option = new FlxSprite(570, 250 + i * 130);
        option.frames = Paths.getSparrowAtlas("menus/pause/option");
        option.animation.addByPrefix("normal", "optionNormal", 1, true);
        option.animation.addByPrefix("selected", "optionSelected", 1, true);
        option.animation.play("normal");
        option.scale.set(3, 3);
        option.cameras = [game.camOther];
        menuItems[i][1].push(option);

        var text = new FlxText(option.x - 340, option.y - 15, FlxG.width, menuItems[i][0]);
        text.setFormat(Paths.font("sonicCD.ttf"), 24, 0xFFFFFFFF, "center", FlxTextBorderStyle.SHADOW, 0xFF000000);
        text.shadowOffset.x += 1;
        text.shadowOffset.y += 3;
        text.cameras = [game.camOther];
        menuItems[i][1].push(text);
    }

    game.canPause = false;
    thisCanOpen = false;

    return;
}

function onSongStart() {
    game.canPause = true;
    thisCanOpen = true;
}

function onUpdatePost(e) {
    if (controls.justPressed("pause") && game.canPause && !PlayState.chartingMode && !isDead && thisCanOpen)
        CustomSubstate.openCustomSubstate('pauseMenu', true);
}

function onCustomSubstateCreate(t) {
    if (t == "pauseMenu") {
        selectedSomething = false;
        changeSelection(0);
        for (i in [overlay, pause]) CustomSubstate.instance.add(i);
        for (i in menuItems) for (o in i[1]) CustomSubstate.instance.add(o);
        pause.animation.play("pause", true, true);
    }
}

function changeSelection(change)
{
    curSelected += change;
    if (curSelected > menuItems.length - 1) curSelected = 0;
    if (curSelected < 0) curSelected = menuItems.length - 1;

    FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);

    for (i in 0...menuItems.length) {
        if (i == curSelected) {
            menuItems[i][1][0].animation.play("selected");
            menuItems[i][1][1].color = 0xFFE0E000;
        } else {
            menuItems[i][1][0].animation.play("normal");
            menuItems[i][1][1].color = 0xFFFFFFFF;
        }
    }
}

function selectSomething()
{
    selectedSomething = true;

    var selected:Bool = true;
    FlxG.sound.play(Paths.sound("confirmMenu"));
    new FlxTimer().start(0.05, function(tmr) {
        selected = !selected;
        menuItems[curSelected][1][1].color = selected ? 0xFFE0E000 : 0xFFFFFFFF;
    }, 21);

    new FlxTimer().start(1.4, function(tmr) {
        switch (curSelected)
        {
            case 0:
                for (i in [overlay, pause]) CustomSubstate.instance.remove(i);
                for (i in menuItems) for (o in i[1]) CustomSubstate.instance.remove(o);
                CustomSubstate.closeCustomSubstate("pauseMenu");

            case 1:
                game.camOther.fade(0xFF000000, 0.5);
                new FlxTimer().start(0.5, function(tmr) {
                    PauseSubState.restartSong(false);
                });

            case 2:
                game.camOther.fade(0xFF000000, 0.5);
                new FlxTimer().start(0.5, function(tmr) {
                    FlxG.sound.playMusic(Paths.music("freakyMenu"), 1);
                    PlayState.checkpointTime = 0;
                    PlayState.campaignMisses = 0;
                    PlayState.songVariation = null;
                    MusicBeatState.switchState(new CustomState(), Paths.hscript("states/MainMenuState"));
                });
        }
    });
}

function onCustomSubstateUpdate(t, e)
{
    if (t == "pauseMenu") {
        if (!selectedSomething) {
            if (controls.UI_UP_P) changeSelection(-1);
            if (controls.UI_DOWN_P) changeSelection(1);
            if (controls.ACCEPT) selectSomething();
        }
    }
}

function onDestroy() {} // this is needed or it will crash upon state reset/switch