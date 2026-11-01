import openfl.Lib;
import backend.ClientPrefs;
import backend.Highscore;
import backend.Controls;
import backend.Song;
import backend.MusicBeatState;
import backend.Discord;
import states.CreditsState;
import states.PlayState;
import states.LoadingState;
import states.CustomState;
import options.OptionsState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.text.FlxTextBorderStyle;
import substates.GameplayChangersSubstate;

// ALSO PLAY VS REPHRASE -pootis

var bg:FlxSprite;
var clouds:FlxBackdrop;
var special:FlxBackdrop;
var curTransform:Bool = true;
var menuTitle:FlxSprite;

var menuItems:Array = [["TRACKS", true, null], ["SETTINGS", true, null], ["GALLERY", false, null], ["CREDITS", false, null]]; // Item, Unlocked by default, FlxText object (added later)
var sonicText:FlxText;
var selector:FlxSprite;
var curSelected:Int = 0;
var curSelectedRemix:Int = 0;
var curSelectedFile:Int = 0;
var selectedSomething:Bool = false;

var bf:FlxSprite;
var dataSelector:FlxSprite;
var arrows:FlxSprite;
var blueFade:FlxSprite;

var menuMode:Bool = false; // false = main, true = tracks
var debug:Bool = false;
var inSubstate:Bool = false;
var leaving:Bool = false;

var songs:Array = [["Thriller Gen", true, true], ["Trinity", false, true]]; // Song name, unlocked by default, has remixes
var remixes:Array = [["", true], [ClientPrefs.data.remixedLegacySongs ? " Remixed" :  " Legacy", false]]; // Remix name, unlocked by default
var files:Array = [[], []];

var page:Int = 0;

using StringTools;

function onCreate()
{
    Paths.clearStoredMemory();

    DiscordClient.changePresence("Main Menu", null);
    Highscore.load();

    FlxG.scaleMode = PlayState.getStageSizeScaleMode();
    resizeWindow(820, 720);

    FlxG.mouse.visible = false;

    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;

    FlxG.camera.alpha = 0;
    new FlxTimer().start(0.001, function(tmr) {
        FlxG.camera.alpha = 1;
        FlxG.camera.flash(0xFF000000, 0.6);
    });

    if (FlxG.save.data.beatenTG || debug) for (i in songs) if (i[0] == "Trinity") i[1] = true;

    if (FlxG.save.data.beatenTrinity || debug) {
        menuItems[2][1] = true;
        menuItems[3][1] = true;

        for (i in remixes) i[1] = true;
    }

    PlayState.checkpointTime = 0;
    PlayState.deathCounter = 0;
    PlayState.campaignMisses = 0;

    if (FlxG.sound.music == null) {
        FlxG.sound.playMusic(Paths.music("freakyMenu"), 1);
        FlxG.sound.music.looped = true;
    }
    FlxG.sound.music.volume = 1;

    bg = new FlxSprite().loadGraphic(Paths.image("menus/main/bg"));
    bg.setGraphicSize(FlxG.width, FlxG.height);

    clouds = new FlxBackdrop(Paths.image("menus/main/clouds"), 0x01);
    clouds.velocity.x = 10;

    special = new FlxBackdrop(Paths.image("menus/main/clouds"), 0x01);
    special.frames = Paths.getSparrowAtlas("menus/main/special");
    special.animation.addByPrefix("swap", "special", 8, false);
    special.velocity.x = FlxG.random.float(-8, -19);

    special.animation.finishCallback = function (fin) {
        clouds.velocity.x = curTransform ? 10 : -10;
        special.velocity.x = curTransform ? FlxG.random.float(-8, -19) : FlxG.random.float(8, 19);
    }

    new FlxTimer().start(10, function(tmr) {
        special.velocity.x = 0;
        curTransform = !curTransform;
        special.animation.play("swap", true, curTransform);
    }, 0);

    menuTitle = new FlxSprite();
    menuTitle.frames = Paths.getSparrowAtlas("menus/main/menuTitles");
    menuTitle.animation.addByPrefix("mainMenu", "mainMenu", 1, true);
    menuTitle.animation.addByPrefix("dataSelect", "dataSelect", 1, true);
    menuTitle.animation.play("mainMenu");

    for (i in [bg, clouds, special, menuTitle]) {
        if (i != bg) i.scale.set(i == menuTitle ? 2.75 : 4, i == menuTitle ? 2.75 : 4);
        i.screenCenter();
        game.add(i);
    }

    menuTitle.y -= 290;

    for (i in 0...menuItems.length) {
        var menuText = new FlxText(0, 0, FlxG.width, menuItems[i][0]);
        menuText.setFormat(Paths.font("sonic2HUD.ttf"), 55, menuItems[i][1] ? 0xFFFFFFFF : 0xFFB4B4B4, "center", FlxTextBorderStyle.SHADOW, 0xFF000000);
        menuText.shadowOffset.x += 1;
        menuText.shadowOffset.y += 3;
        menuText.screenCenter();
        menuText.y += i * 70 - 80;
        menuItems[i][2] = menuText;
        game.add(menuText);
    }

    sonicText = new FlxText(0, 550, FlxG.width, "PLAY SONIC'S GAME TO ACCESS THIS OPTION");
    sonicText.setFormat(Paths.font("sonic2HUD.ttf"), 45, 0xFFFF0000, "center", FlxTextBorderStyle.SHADOW, 0xFF000000);
    sonicText.shadowOffset.x += 1;
    sonicText.shadowOffset.y += 3;
    sonicText.screenCenter(0x01);
    sonicText.visible = false;
    game.add(sonicText);

    selector = new FlxSprite().loadGraphic(Paths.image("menus/main/selector"));
    selector.scale.set(4, 4);
    selector.screenCenter(0x01);
    game.add(selector);

    changeSelection(0, true);
    Paths.sound("confirmMenu");

    for (i in 0...2)
    {
        var file = new FlxSprite().loadGraphic(Paths.image("menus/main/file"));
        file.scale.set(3.5, 3.5);
        file.alpha = 0.001;
        file.screenCenter(0x10);
        file.x = 160 + i * 407;
        file.y += 50;
        files[i].push(file);
        game.add(file);

        var icon = new FlxSprite().loadGraphic(Paths.image("menus/main/icons/Thriller Gen"));
        icon.scale.set(3.51, 3.51);
        icon.alpha = 0.001;
        icon.x = file.x - 2;
        icon.y = file.y - 112;
        files[i].push(icon);
        game.add(icon);

        var title = new FlxSprite().loadGraphic(Paths.image("menus/main/titles/Thriller Gen"));
        title.scale.set(3.5, 3.5);
        title.alpha = 0.001;
        title.x = file.x + 10;
        title.y = file.y + 100;
        files[i].push(title);
        game.add(title);

        var lock = new FlxSprite().loadGraphic(Paths.image("menus/main/x")); // honestly just for trinity but might as well put it here
        lock.scale.set(3.5, 3.5);
        lock.alpha = 0.001;
        lock.visible = false;
        lock.x = file.x + 25;
        lock.y = file.y + 240;
        files[i].push(lock);
        game.add(lock);

        var staticSprite = new FlxSprite();
        staticSprite.frames = Paths.getSparrowAtlas("menus/main/static");
        staticSprite.animation.addByPrefix("static", "static", 12, true);
        staticSprite.animation.play("static");
        staticSprite.scale.set(3.51, 3.51);
        staticSprite.alpha = 0.001;
        staticSprite.x = icon.x;
        staticSprite.y = icon.y;
        staticSprite.visible = false;
        files[i].push(staticSprite);
        game.add(staticSprite);

        var song:Array = [];
        files[i].push(song);
    }

    bf = new FlxSprite(0, 560).loadGraphic(Paths.image("menus/main/boyfriend"));
    bf.scale.set(4, 4);
    bf.alpha = 0.001;
    game.add(bf);

    dataSelector = new FlxSprite(0, 320).loadGraphic(Paths.image("menus/main/select"));
    dataSelector.scale.set(3.5, 3.5);
    dataSelector.alpha = 0.001;
    game.add(dataSelector);

    arrows = new FlxSprite(250, 205).loadGraphic(Paths.image("menus/main/arrows"));
    arrows.scale.set(3.5, 3.5);
    arrows.alpha = 0.001;
    if (FlxG.save.data.beatenTrinity || debug) game.add(arrows);

    blueFade = new FlxSprite(0, 0).makeGraphic(100, 100, 0xFF0000FF);
    blueFade.scale.set(100, 100);
    blueFade.screenCenter();
    blueFade.blend = 9;
    blueFade.alpha = 0.001;
    game.add(blueFade);

    new FlxTimer().start(0.5, function(tmr) {
        arrows.visible = !arrows.visible;
    }, 0);
    
    if (CustomState.dataSelect) changeMenus(true);

    Paths.clearUnusedMemory();
}

function reloadSongs()
{
    for (i in 0...files.length) {
        var num = i + page;
        files[i][1].loadGraphic(Paths.image("menus/main/icons/" + songs[num][0] + remixes[curSelectedRemix][0]));
        files[i][2].loadGraphic(Paths.image("menus/main/titles/" + songs[num][0] + remixes[curSelectedRemix][0]));
        files[i][5] = songs[num];
    }
}

function changeSelection(change, silent)
{
    if (!silent) FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);

    if (!menuMode) {
        curSelected += change;
        if (curSelected > menuItems.length - 1) curSelected = 0;
        if (curSelected < 0) curSelected = menuItems.length - 1;

        for (i in 0...menuItems.length) {
            if (i == curSelected) {
                menuItems[i][2].color = menuItems[i][1] ? 0xFFFCFC00 : 0xFFB5B500;
            } else {
                menuItems[i][2].color = menuItems[i][1] ? 0xFFFFFFFF : 0xFFB4B4B4;
            }
        }

        selector.y = menuItems[curSelected][2].y + 25;
        selector.color = menuItems[curSelected][2].color;
    } else {
        curSelected += change;
        if (curSelected > songs.length - 1) curSelected = 0;
        if (curSelected < 0) curSelected = songs.length - 1;

        curSelectedFile += change;
        if (curSelectedFile > files.length - 1) curSelectedFile = 0;
        if (curSelectedFile < 0) curSelectedFile = files.length - 1;

        curSelectedRemix = 0;

        if (curSelected % 2 == 0) page = curSelected;
        if (change == -1 && curSelected == 1) page = 0; // im brain damaged so shitty fix
        if (change == -1 && curSelected == 3) page = 2;

        reloadSongs();

        dataSelector.x = files[curSelectedFile][0].x - 10;
        bf.x = files[curSelectedFile][0].x + 20;
        bf.alpha = files[curSelectedFile][5][1] ? 1 : 0.001;
        arrows.x = files[curSelectedFile][0].x + 30;

        for (i in 0...files.length) {
            FlxTween.cancelTweensOf(files[i][4]);
            files[i][4].alpha = 1;
            if (!files[i][5][1] == false) {
                files[i][4].visible = (i != curSelectedFile) ? true : false;
            } else {
                files[i][4].visible = true;
            }

            if (i == curSelectedFile) {
                if (files[i][5][2]) {
                    arrows.alpha = files[i][5][1] ? 1 : 0.001;
                } else {
                    arrows.alpha = 0.001;
                }
            }
            files[i][3].visible = files[i][5][1] ? false : true;
        }
    }
}

function changeMix(change, ?silent = false)
{
    if (!menuMode || !files[curSelectedFile][5][1] || !files[curSelectedFile][5][2] || !FlxG.save.data.beatenTrinity && !debug) return;

    if (!silent) FlxG.sound.play(Paths.sound("scrollMenu"), 0.8);

    curSelectedRemix += change;
    if (curSelectedRemix > remixes.length - 1) curSelectedRemix = 0;
    if (curSelectedRemix < 0) curSelectedRemix = remixes.length - 1;

    if (remixes[curSelectedRemix][1] == false) {
        changeMix(change + 1, true);
        return;
    }

    files[curSelectedFile][1].loadGraphic(Paths.image("menus/main/icons/" + files[curSelectedFile][5][0] + remixes[curSelectedRemix][0]));
    files[curSelectedFile][2].loadGraphic(Paths.image("menus/main/titles/" + files[curSelectedFile][5][0] + remixes[curSelectedRemix][0]));

    FlxTween.cancelTweensOf(files[curSelectedFile][4]);
    files[curSelectedFile][4].visible = true;
    files[curSelectedFile][4].alpha = 1;
    FlxTween.tween(files[curSelectedFile][4], {alpha: 0.001}, 0.5, {onComplete: function (twn) {
        files[curSelectedFile][4].visible = false;
        files[curSelectedFile][4].alpha = 1;
    }});
}

function changeMenus(which:Bool = false)
{
    CustomState.dataSelect = which;

    menuMode = which;
    curSelected = 0;
    curSelectedFile = 0;
    curSelectedRemix = 0;
    changeSelection(0, true);
    selectedSomething = false;
    menuTitle.animation.play(which ? "dataSelect" : "mainMenu");
    menuTitle.offset.x = which ? 20 : 0;

    if (menuMode) {
        for (i in menuItems) i[2].alpha = 0.001;
        for (i in [selector, sonicText]) i.alpha = 0.001;
        for (i in files) for (o in i) if (o != i[5]) o.alpha = 1;
        for (i in [bf, dataSelector, arrows]) i.alpha = 1;
    } else {
        for (i in menuItems) i[2].alpha = 1;
        for (i in [selector, sonicText]) i.alpha = 1; 
        for (i in files) for (o in i) {
            if (o == i[4]) FlxTween.cancelTweensOf(o);
            if (o != i[5]) o.alpha = 0.001;
        }
        for (i in [bf, dataSelector, arrows]) i.alpha = 0.001;
    }
}

function switchState(state:String, stopMusic:Bool = false)
{
    FlxTween.tween(blueFade, {alpha: 1}, 0.5);
    FlxG.camera.fade(0xFF000000, 0.7);
    new FlxTimer().start(0.75, function(tmr) {
        if (stopMusic) {
            FlxG.sound.music.stop();
            FlxG.sound.music = null;
        }
        MusicBeatState.switchState(new CustomState(), Paths.hscript(state));
    });
}

function selectSomething()
{
    if (!menuMode) {
        selectedSomething = true;
        if (menuItems[curSelected][1]) {
            FlxG.sound.play(Paths.sound("confirmMenu"));
            var selected:Bool = true;
            new FlxTimer().start(0.05, function(tmr) {
                selected = !selected;
                menuItems[curSelected][2].color = selected ? 0xFFFFFFFF : 0xFFFCFC00;
                selector.color = menuItems[curSelected][2].color;
            }, 21);

            new FlxTimer().start(1.4, function(tmr) {
                switch (curSelected)
                {
                    case 0: changeMenus(true);
                    case 1: switchState("states/OptionsState", false);
                    case 2: switchState("states/GalleryState", true);
                    case 3: switchState("states/CreditsState", false);
                    case 4: switchState("states/EndCreditsState", true);
                }
            });
        } else {
            new FlxTimer().start(0.05, function(tmr) {
                sonicText.visible = !sonicText.visible;
            }, 16);

            FlxG.sound.play(Paths.sound("denied"));

            new FlxTimer().start(0.8, function(tmr) {
                selectedSomething = false;
            });
        }
    } else {
        selectedSomething = true;
        if (!songs[curSelected][1]) {
            FlxG.sound.play(Paths.sound("denied"));
            new FlxTimer().start(0.8, function(tmr) {
                selectedSomething = false;
            });
        } else {
            FlxG.sound.play(Paths.sound("selectSong"));
            FlxG.camera.fade(0xFF000000, 1.25);

            new FlxTimer().start(0.05, function(tmr) {
                dataSelector.visible = !dataSelector.visible;
            }, 21);

            FlxTween.tween(blueFade, {alpha: 1}, 1.1);
            FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.9);

            var songName:String = files[curSelectedFile][5][0] + remixes[curSelectedRemix][0];
            var difficName:String = files[curSelectedFile][5][0] + remixes[curSelectedRemix][0];

            if (remixes[curSelectedRemix][0] == " Remixed") {
                songName = files[curSelectedFile][5][0] + " Legacy";
                difficName = files[curSelectedFile][5][0] + " Legacy-remixed";
            }

            new FlxTimer().start(1.25, function(tmr) {
                PlayState.SONG = Song.loadFromJson(difficName, songName);
                PlayState.isStoryMode = false;
                PlayState.storyDifficulty = 0;
                PlayState.songVariation = remixes[curSelectedRemix][0] == " Remixed" ? "remixed" : null;
                FlxG.mouse.visible = false;
                resizeWindow(1280, 720);
                FlxTimer.globalManager.forEach(function(tmr:FlxTimer) tmr.active = false);
                FlxTween.globalManager.forEach(function(twn:FlxTween) twn.active = false);
                PlayState.checkpointTime = 0;
                LoadingState.loadAndSwitchState(new PlayState());
            });
        }
    }
}

function resizeWindow(width:Int, height:Int)
{
    FlxG.resizeWindow(width, height);
    FlxG.resizeGame(width, height);
    var resolutionX = Math.ceil(Lib.current.stage.window.display.currentMode.width * Lib.current.stage.window.scale);
    var resolutionY = Math.ceil(Lib.current.stage.window.display.currentMode.height * Lib.current.stage.window.scale);
    Lib.application.window.x = (resolutionX - Lib.application.window.width) / 2;
    Lib.application.window.y = (resolutionY - Lib.application.window.height) / 2;
}

function onUpdate(e)
{
    if (controls.justPressed("debug_1") && debug && !selectedSomething) {
        FlxG.camera.alpha = 0;
        MusicBeatState.switchState(new CustomState(), Paths.hscript("states/MasterEditorState"));
    }

    if (inSubstate) {
        if (controls.BACK) {
            selectedSomething = false;
            new FlxTimer().start(0.001, function(tmr) {
                inSubstate = false;
            });
        }
    }

    if (!selectedSomething) {
        if (controls.UI_UP_P) if (!menuMode) changeSelection(-1, false) else changeMix(-1);
        if (controls.UI_DOWN_P) if (!menuMode) changeSelection(1, false) else changeMix(1);
        if (controls.UI_LEFT_P && menuMode) changeSelection(-1, false);
        if (controls.UI_RIGHT_P && menuMode) changeSelection(1, false);
        if (controls.ACCEPT) selectSomething();
        if (FlxG.keys.justPressed.CONTROL && debug) {
            inSubstate = true;
            selectedSomething = true;
            game.persistentUpdate = true;
			openSubState(new GameplayChangersSubstate());
        }
        if (controls.BACK && !inSubstate && !leaving) { 
            if (menuMode) {
                changeMenus(false);
                FlxG.sound.play(Paths.sound("cancelMenu"));
            } else {
                leaving = true;
                FlxG.camera.fade(0xFF000000, 0.9);
                FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.9);
                FlxTween.tween(blueFade, {alpha: 1}, 0.6);
                new FlxTimer().start(0.95, function(tmr) {
                    MusicBeatState.switchState(new CustomState(), Paths.hscript("states/TitleState"));
                });
            }
        }
    }
}

function onDestroy() {} // this is needed or it will crash on state switch/reset. sscript is so fucking bad