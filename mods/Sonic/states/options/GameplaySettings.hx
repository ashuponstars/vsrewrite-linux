import states.CustomState;
import backend.MusicBeatState;
import backend.Discord;
import backend.Controls;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;
import Reflect;

var bg:FlxSprite;
var menuTitle:FlxSprite;
var leaving:Bool = false;
var blueFade:FlxSprite;
var curSelected:Int = 0;
var curValue:Dynamic;
var options:Array = [ // name, save name, description, type
    ["Downscroll", "downScroll", "If checked, your notes will scroll down instead of up.", "bool"],
    ["Ghost Tapping", "ghostTapping", "If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.", "bool"],
    ["Disable Reset Button", "noReset", "If checked, pressing Reset won't do anything.", "bool"],
    ["Hitsound Volume", "hitsoundVolume", "How loud should the note hitsound be?", "percent", [0, 1, 0.1, 20]],
    ["Rating Offset", "ratingOffset", 'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.', "int", [-30, 30, 1, 20, "MS"]],
    ["Sick Hit Window", "sickWindow", 'Changes the amount of time you have\nfor hitting a "Sick" in milliseconds.', "int", [15, 45, 1, 15, "MS"]],
    ["Good Hit Window", "goodWindow", 'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.', "int", [15, 90, 1, 30, "MS"]],
    ["Bad Hit Window", "badWindow", 'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.', "int", [15, 135, 1, 60, "MS"]],
    ["Safe Frames", "safeFrames", 'Changes how many frames you have for\nhitting a note earlier or late.', "float", [2, 10, 0.1, 5, ""]],
    ["Sustains as One Note", "guitarHeroSustains", "If checked, sustain notes can't be pressed if you miss,\nand count as a single hit/miss.\nUncheck this if you prefer the old input system.", "bool"]
];

var descriptionText:FlxText;
var hitMinMax:Bool = false;
var optionsAssetsArray:Array = [];

function onCreate()
{
    DiscordClient.changePresence("Gameplay Settings Menu", null);

    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;

    new FlxTimer().start(0.001, function(tmr) {
        FlxG.camera.alpha = 1;
        FlxG.camera.flash(0xFF000000, 0.6);
    });

    bg = new FlxSprite().loadGraphic(Paths.image("menus/options/bg"));
    bg.scale.set(3.25, 3.25);

    menuTitle = new FlxSprite().loadGraphic(Paths.image("menus/options/settings"));
    menuTitle.scale.set(2.5, 2.5);

    for (i in [bg, menuTitle]) {
        i.screenCenter();
        game.add(i);
    }

    menuTitle.y -= 310;

    for (i in 0...options.length)
    {
        var text:FlxText = new FlxText(90, 115 + i * 50, FlxG.width, options[i][0].toUpperCase());
        text.setFormat(Paths.font("sonic2HUD.ttf"), 44, 0xFFFFFFFF, "left", FlxTextBorderStyle.SHADOW, 0xFF000000);
        text.shadowOffset.x += 1;
        text.shadowOffset.y += 3;
        game.add(text);

        var assetArray:Array = [text];

        switch (options[i][3])
        {
            case "bool":
                var checkbox = new FlxSprite(text.x + 550, text.y + 10);
                checkbox.frames = Paths.getSparrowAtlas("menus/options/checkbox");
                checkbox.animation.addByPrefix("on", "checkboxYES", 1, true);
                checkbox.animation.addByPrefix("off", "checkboxNO", 1, true);
                checkbox.animation.play(Reflect.getProperty(ClientPrefs.data, options[i][1]) ? "on" : "off");
                checkbox.scale.set(2.2, 2.2);
                game.add(checkbox);
                assetArray.push(checkbox);

            case "percent":
                var percent = new FlxSprite(text.x + 490, text.y);
                percent.frames = Paths.getSparrowAtlas("menus/options/percent");
                percent.animation.addByPrefix("0", "percent00", 1, true); // probably a better way to do this but whatever. yanderedev GO
                percent.animation.addByPrefix("0.1", "percent01", 1, true);
                percent.animation.addByPrefix("0.2", "percent02", 1, true);
                percent.animation.addByPrefix("0.3", "percent03", 1, true);
                percent.animation.addByPrefix("0.4", "percent04", 1, true);
                percent.animation.addByPrefix("0.5", "percent05", 1, true);
                percent.animation.addByPrefix("0.6", "percent06", 1, true);
                percent.animation.addByPrefix("0.7", "percent07", 1, true);
                percent.animation.addByPrefix("0.8", "percent08", 1, true);
                percent.animation.addByPrefix("0.9", "percent09", 1, true);   
                percent.animation.addByPrefix("1", "percent10", 1, true);
                percent.animation.play(Std.parseFloat(Reflect.getProperty(ClientPrefs.data, options[i][1])));            
                game.add(percent);
                assetArray.push(percent);

            case "int", "float":
                var valueText:FlxText = new FlxText(text.x + 530, text.y, text.width, Reflect.getProperty(ClientPrefs.data, options[i][1]) + " " + options[i][4][4]);
                valueText.setFormat(Paths.font("sonic2HUD.ttf"), 44, 0xFFFFFFFF, "left", FlxTextBorderStyle.SHADOW, 0xFF000000);
                valueText.shadowOffset.x += 1;
                valueText.shadowOffset.y += 3;
                game.add(valueText);
                assetArray.push(valueText);
        }

        optionsAssetsArray.push(assetArray);
    }

    descriptionText = new FlxText(0, 0, FlxG.width, "hello!");
    descriptionText.setFormat(Paths.font("sonic-1-hud-font.ttf"), 32, 0xFFFFFFFF, "center", FlxTextBorderStyle.SHADOW, 0xFF000000);
    descriptionText.screenCenter(0x01);
    descriptionText.y = 640;
    descriptionText.shadowOffset.x += 1;
    descriptionText.shadowOffset.y += 3;
    game.add(descriptionText);

    blueFade = new FlxSprite(0, 0).makeGraphic(100, 100, 0xFF0000FF);
    blueFade.scale.set(100, 100);
    blueFade.screenCenter();
    blueFade.blend = 9;
    blueFade.alpha = 0.001;
    game.add(blueFade);

    changeSelection(0, true);
}

function changeSelection(change, silent)
{
    if (!silent) FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);

    curSelected += change;
    if (curSelected > options.length - 1) curSelected = 0;
    if (curSelected < 0) curSelected = options.length - 1;

    for (i in 0...optionsAssetsArray.length) {
        if (i == curSelected) {
            optionsAssetsArray[i][0].color = 0xFFFCFC00;
        } else {
            optionsAssetsArray[i][0].color = 0xFFFFFFFF;
        }
    }

    descriptionText.text = options[curSelected][2];
    curValue = Reflect.getProperty(ClientPrefs.data, options[curSelected][1]);
}

function changeSetting(change, ?silent)
{
    switch (options[curSelected][3])
    {
        case "bool":
            if (!silent) FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
            Reflect.setProperty(ClientPrefs.data, options[curSelected][1], !curValue);
            curValue = Reflect.getProperty(ClientPrefs.data, options[curSelected][1]);
            optionsAssetsArray[curSelected][1].animation.play(Reflect.getProperty(ClientPrefs.data, options[curSelected][1]) ? "on" : "off");

        case "percent":
            if (change == 0) return;
            var actualChange:Float = Std.parseFloat(curValue + change);
            if (actualChange > options[curSelected][4][1] || actualChange < options[curSelected][4][0]) {
                return;
            } else {
                Reflect.setProperty(ClientPrefs.data, options[curSelected][1], actualChange);
                curValue = Reflect.getProperty(ClientPrefs.data, options[curSelected][1]);
            }

            if (!silent || options[curSelected][1] == "hitsoundVolume") FlxG.sound.play(Paths.sound(options[curSelected][1] == "hitsoundVolume" ? "hitsound" : "scrollMenu"), options[curSelected][1] == "hitsoundVolume" ? ClientPrefs.data.hitsoundVolume : 0.8);
            optionsAssetsArray[curSelected][1].animation.play(Std.parseFloat(Reflect.getProperty(ClientPrefs.data, options[curSelected][1])));

        case "int", "float":
            if (change == 0) return;
            var actualChange:Float = Std.parseFloat(curValue + change);
            if (actualChange > options[curSelected][4][1] || actualChange < options[curSelected][4][0]) {
                hitMinMax = true;
                return;
            } else {
                hitMinMax = false;
                Reflect.setProperty(ClientPrefs.data, options[curSelected][1], actualChange);
                curValue = Reflect.getProperty(ClientPrefs.data, options[curSelected][1]);
            }

            if (!silent) FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
            optionsAssetsArray[curSelected][1].text = Reflect.getProperty(ClientPrefs.data, options[curSelected][1]) + " " + options[curSelected][4][4];
    }
}

var holdTime:Float = 0;
function onUpdate(e) {
    if (leaving) return;

    if (controls.BACK) {
        leaving = true;
        FlxG.sound.play(Paths.sound("cancelMenu"));
        FlxTween.tween(blueFade, {alpha: 1}, 0.5);
        FlxG.camera.fade(0xFF000000, 0.7);
        new FlxTimer().start(0.75, function(tmr) {
            MusicBeatState.switchState(new CustomState(), Paths.hscript("states/OptionsState"));
        });
    }

    if (controls.UI_UP_P || controls.UI_DOWN_P) changeSelection(controls.UI_UP_P ? -1 : 1, false);
    if (controls.ACCEPT) changeSetting(0);
    if ((controls.UI_LEFT || controls.UI_RIGHT)) {
        var pressed = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
        var value = options[curSelected][4] == null ? 1 : options[curSelected][4][2];
        var actValue = controls.UI_LEFT ? -value : value;
        if (options[curSelected][3] != "bool") {
            holdTime += e;

            if (pressed || holdTime > 0.5) {
                changeSetting(actValue, holdTime > 0.5 ? true : false);
            }
        } else if (pressed) {
            changeSetting(actValue, false);
        }
    } else if ((controls.UI_LEFT_R || controls.UI_RIGHT_R)) {
        if (holdTime > 0.5 && !hitMinMax && options[curSelected][1] != "hitsoundVolume") FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);
        holdTime = 0;
    }
}