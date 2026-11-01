// this actually sucks
// a lot of this is copied from access denied which i also coded - pootis

import backend.Controls;
import backend.Discord;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.sound.FlxSound;
import objects.MaigoSpeaker;
import Math;
import Main;

var loaded:Bool = false;
var overlay:FlxSprite;

var camGame:FlxCamera;
var textCam:FlxCamera;

var infoText:FlxText;
var entries:Array = [
    ["meet-maigo", "Maigo", "music", "false", null, [""]],
    ["thriller-gen", "Thriller Gen Encore", "full", "true", null, ["", "instrumental"]],
    ["trinity", "Trinity Encore", "full", "true", null, ["", "instrumental"]],
    ["thriller-gen-legacy", "Thriller Gen", "full", "true", null, ["", "instrumental", "remixed", "remixedInstrumental"]],
    ["trinity-legacy", "Trinity", "full", "true", null, ["", "instrumental", "remixed", "remixedInstrumental"]],
    ["introround2", "Ready For Round Two", "music", "false", null, [""]],
    ["title", "Title Screen", "sound", "false", null, [""]],
    ["freakyMenu", "Path Chooser Reprise", "music", "false", null, [""]],
    ["offsetSong", "Delay Menu", "music", "false", null, [""]],
    ["drowning", "Drowning", "sound", "false", null, [""]],
    ["Victory", "Victory", "sound", "false", null, [""]],
    ["youreTooCool", "You're Too Cool", "music", "false", null, [""]],
    ["theEnd", "Post Credits", "music", "false", null, [""]],
    ["scrappedTGESection", "Scrapped Thriller Gen Encore Section", "music", "false", null, [""]],
    ["trinityEncoreUnfinished", "Trinity Encore Old WIP", "music", "true", null, ["", "instrumental"]],
    ["terrorizerWIP", "Terrorizer Unfinished", "music", "false", null, [""]],
    ["terrorizerDangenWIP", "Terrorizer Dangen Mix Unfinished", "music", "false", null, [""]],
    ["tomodachiAsobi", "Tomodachi Asobi Unfinished", "music", "false", null, [""]],
    ["SonicTGE", "Sonic Game Over Voice Lines", "sound-gameover", "false", "7", [""]],
    ["SonicTGEMidareta", "Midareta Sonic Game Over Voice Lines", "sound-gameover", "false", "5", [""]],
    ["SonicTrinity", "Wurugashikoi Sonic Game Over Voice Lines", "sound-gameover", "false", "9", [""]],
    ["Majin", "Majin Sonic Game Over Voice Lines", "sound-gameover", "false", "10", [""]],
    ["X", "2011X Game Over Voice Lines", "sound-gameover", "false", "11", [""]],
    ["Fusion", "MajinX Fusion Game Over Voice Lines", "sound-gameover", "false", "4", [""]],
    ["XRodentRap", "RodentRap Sonic Game Over Voice Lines", "sound-gameover", "false", "17", [""]],
    ["LordX", "Lord X Game Over Voice Lines", "sound-gameover", "false", "11", [""]]
];

var curSelected:Int = 0;
var curVariant:Int = 0;

var voices:FlxSound;
var opponentVoices:FlxSound;
var paused:Bool = false;

var toggleRemixesHitbox:FlxSprite;
var switchLeftHitbox:FlxSprite;
var playPauseHitbox:FlxSprite;
var switchRightHitbox:FlxSprite;
var restartSongHitbox:FlxSprite;

var toggleRemixesButton:FlxSprite;
var switchLeftButton:FlxSprite;
var playPauseButton:FlxSprite;
var switchRightButton:FlxSprite;
var restartSongButton:FlxSprite;
var back:FlxSprite;
var customCursor:FlxSprite;
var preloadEverything:Bool = false;
var leaving:Bool = false;
var voiceLine:Int = 0;

var maigo:MaigoSpeaker;
var maigoDialogues:Array<String> = [];

var modDisclaimerBacking:FlxSprite;
var modDisclaimerText:FlxText;

var songNameTween:FlxTween;

using StringTools;

function onCreate()
{
    camGame = initPsychCamera();

    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;

    DiscordClient.changePresence("Gallery - Music Player", null);

    textCam = new FlxCamera(290, 10, 273, 126);
    textCam.bgColor = 0xFF393C10;

    FlxG.camera.bgColor = 00000000;

    FlxG.cameras.remove(FlxG.camera, false);
    FlxG.cameras.add(textCam, false);
    FlxG.cameras.add(FlxG.camera, true);

    infoText = new FlxText(23, 40, -1, "LOADING");
    infoText.setFormat(Paths.font("3dBlast.ttf"), 32, 0xFFEEFAD5, "left");
    infoText.cameras = [textCam];
    game.add(infoText);

    overlay = new FlxSprite(0, 0);
    overlay.frames = Paths.getSparrowAtlas("menus/gallery/room");
    overlay.animation.addByPrefix("main", "room", 15, true);
    overlay.animation.addByPrefix("discmanZoom", "discmanZoom", 15, false);
    overlay.animation.play("discmanZoom", true, false, 6);
    overlay.scale.set(3.5, 3.5);
    overlay.screenCenter();
    game.add(overlay);

    toggleRemixesHitbox = new FlxSprite(180, 546).makeGraphic(43, 49, 0xFFFFFFFF);
    switchLeftHitbox = new FlxSprite(245, 566).makeGraphic(70, 63, 0xFFFFFFFF);
    playPauseHitbox = new FlxSprite(340, 532).makeGraphic(165, 160, 0xFFFFFFFF);
    switchRightHitbox = new FlxSprite(531, 566).makeGraphic(70, 63, 0xFFFFFFFF);
    restartSongHitbox = new FlxSprite(625, 546).makeGraphic(43, 49, 0xFFFFFFFF);

    toggleRemixesButton = new FlxSprite();
    switchLeftButton = new FlxSprite();
    playPauseButton = new FlxSprite();
    switchRightButton = new FlxSprite();
    restartSongButton = new FlxSprite();

    for (i in [toggleRemixesButton, switchLeftButton, playPauseButton, switchRightButton, restartSongButton]) {
        i.frames = Paths.getSparrowAtlas("menus/gallery/discmanButtonPress");
        i.screenCenter();
        i.scale.set(3.5, 3.5);
        i.alpha = 0.001;
        i.visible = true;
        game.add(i);
    }

    restartSongButton.offset.x = -0.1; // lol

    toggleRemixesButton.animation.addByPrefix("button", "farLeft0", 1, false);
    switchLeftButton.animation.addByPrefix("button", "left0", 1, false);
    playPauseButton.animation.addByPrefix("button", "center0", 1, false);
    switchRightButton.animation.addByPrefix("button", "right0", 1, false);
    restartSongButton.animation.addByPrefix("button", "farRight0", 1, false);

    toggleRemixesButton.animation.addByPrefix("buttonHighlighted", "farLeft-highlighted", 1, false);
    switchLeftButton.animation.addByPrefix("buttonHighlighted", "left-highlighted", 1, false);
    playPauseButton.animation.addByPrefix("buttonHighlighted", "center-highlighted", 1, false);
    switchRightButton.animation.addByPrefix("buttonHighlighted", "right-highlighted", 1, false);
    restartSongButton.animation.addByPrefix("buttonHighlighted", "farRight-highlighted", 1, false);

    for (i in [toggleRemixesButton, switchLeftButton, playPauseButton, switchRightButton, restartSongButton]) i.animation.play('button');

    for (i in [toggleRemixesHitbox, switchLeftHitbox, playPauseHitbox, switchRightHitbox, restartSongHitbox]) {
        i.alpha = 0;
        game.add(i);
    }

    voices = FlxG.sound.play(Paths.sound("confirmMenu"), 0);
    voices.pause();

    opponentVoices = FlxG.sound.play(Paths.sound("title"), 0);
    opponentVoices.pause();

    if (preloadEverything) {
        new FlxTimer().start(0.5, function(tmr) {
            for (i in entries) {
                var internalName:String = i[0];
                if (internalName.endsWith("-remixed")) internalName = StringTools.replace(internalName, "-remixed", "");
        
                switch (i[2])
                {
                    case "music": Paths.music(internalName);
        
                    case "full":
                        Paths.inst(internalName, null);
                        Paths.voices(internalName, "Player", null);
                        Paths.voices(internalName, "Opponent", null);

                        if (Paths.fileExists("songs/" + internalName + "/Inst-remixed.ogg", "SOUND", false)) Paths.inst(internalName, "remixed");
                        if (Paths.fileExists("songs/" + internalName + "/Voices-Player-remixed.ogg", "SOUND", false)) Paths.voices(internalName, "Player", "remixed");
                        if (Paths.fileExists("songs/" + internalName + "/Voices-Opponent-remixed.ogg", "SOUND", false)) Paths.voices(internalName, "Opponent", "remixed");
        
                    case "inst":
                        Paths.inst(internalName, null);
                        if (Paths.fileExists("songs/" + internalName + "/Inst-remixed.ogg", "SOUND", false)) Paths.inst(internalName, "remixed");
        
                    case "voices":
                        Paths.voices(internalName, "Player", null);
                        Paths.voices(internalName, "Opponent", null);

                        if (Paths.fileExists("songs/" + internalName + "/Voices-Player-remixed.ogg", "SOUND", false)) Paths.voices(internalName, "Player", "remixed");
                        if (Paths.fileExists("songs/" + internalName + "/Voices-Opponent-remixed.ogg", "SOUND", false)) Paths.voices(internalName, "Opponent", "remixed");
        
                    case "sound": Paths.sound(internalName);
                    case "sound-gameover": for (i in 0...Std.int(i[4])) Paths.sound("gameOverLines/" + internalName + "/" + i[4]);
                }
            }

            loaded = true;
            changeSelection(0, true, false);
            changeVariant(0);
        });
    } else {
        loaded = true;
        changeSelection(0, true, false);
        changeVariant(0);
    }

    back = new FlxSprite(10, 635).loadGraphic(Paths.image("menus/options/back"));
    back.scale.set(3, 3);
    back.updateHitbox();
    back.alpha = 0.001;
    game.add(back);

    maigo = new MaigoSpeaker();
    game.add(maigo);

    maigoDialogues = FlxG.save.data.seenMaigoDialogues;

    modDisclaimerBacking = new FlxSprite(320).makeGraphic(10, 10, 0xFF000000);
    modDisclaimerBacking.scale.set(100, 7);
    modDisclaimerBacking.screenCenter(0x10);
    modDisclaimerBacking.alpha = 0.001;
    game.add(modDisclaimerBacking);

    modDisclaimerText = new FlxText(0, 620, FlxG.width, "");
    modDisclaimerText.setFormat(Paths.font("sonic2HUD.ttf"), 41, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000);
    modDisclaimerText.borderSize = 2;
    modDisclaimerText.screenCenter(0x10);
    game.add(modDisclaimerText);

    customCursor = new FlxSprite(-100, -100); // this really sucks
    customCursor.frames = Paths.getSparrowAtlas("cursor");
    customCursor.animation.addByPrefix("default", "default", 24, false);
    customCursor.animation.addByPrefix("wait", "wait", 24, false);
    customCursor.animation.addByPrefix("hover", "hover", 24, false);
    customCursor.animation.play(preloadEverything ? "wait" : "default");
    customCursor.scale.set(1.5, 1.5);
    game.add(customCursor);

    Main.fpsVar.defaultColor = 0xFF000000;

    CustomState.dataSelect = true;
    FlxG.autoPause = false;

    var seenDialogue:Bool = false;
    for (i in maigoDialogues) {
        if (i == "maigoDiscman") {
            seenDialogue = true;
            break;
        }
    }

    if (!seenDialogue) {
        maigo.currentlySpeaking = true;
        new FlxTimer().start(0.7, function(tmr) {
            FlxTween.tween(FlxG.sound.music, {volume: 0.3}, 0.2);
            maigo.startDialogue([
                ["This is my music player!", "hype", "musicPlayer/0", 0.05, 1.3],
                ["Use the center button to pause and resume songs.", "talk", "musicPlayer/1", 0.05, 1.6, 39],
                ["The left and right buttons can be used to navigate between tracks!", "talk", "musicPlayer/2", 0.05, 1.4, 36],
                ["You can also use the far left button to change between versions of some songs, and it also can swap through different voice clips you may come across!", "talk", "musicPlayer/3", 0.05, 1.6, 22],
                ["And lastly, the far right button, which can be used to restart the music.", "talk", "musicPlayer/4", 0.05, 1.3, 32],
                ["Very practical, right?", "talk", "musicPlayer/5", 0.05, 0.9],
                ["Have fun!", "hype", "musicPlayer/6", 0.05, 1.3],
            ]);
            maigo.onStartDialogue = function(d:Array<Dynamic>)
            {
                switch (d[2])
                {
                    case "musicPlayer/1":
                        playPauseButton.alpha = 1;
                        playPauseButton.animation.play("buttonHighlighted");

                    case "musicPlayer/2":
                        playPauseButton.alpha = 0.001;
                        playPauseButton.animation.play("button");
                        for (i in [switchLeftButton, switchRightButton]) {
                            i.alpha = 1;
                            i.animation.play("buttonHighlighted");
                        }

                    case "musicPlayer/3":
                        for (i in [switchLeftButton, switchRightButton]) {
                            i.alpha = 0.001;
                            i.animation.play("button");
                        }
                        toggleRemixesButton.alpha = 1;
                        toggleRemixesButton.animation.play("buttonHighlighted");
                        maigo.text.x = 0;
                        maigo.icon.x = 610;

                    case "musicPlayer/4":
                        toggleRemixesButton.alpha = 0.001;
                        toggleRemixesButton.animation.play("button");
                        restartSongButton.alpha = 1;
                        restartSongButton.animation.play("buttonHighlighted");
                        maigo.text.x = 258;
                        maigo.icon.x = 70;

                    case "musicPlayer/5":
                        restartSongButton.alpha = 0.001;
                        restartSongButton.animation.play("button");
                }
            }
            maigo.onEndReached = function ()
            {  
                back.alpha = 1;
                FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.2);
                maigoDialogues.push("maigoDiscman");
            }
        });
    } else {
        back.alpha = 1;
    }

    songNameTween = FlxTween.tween(infoText, {x: -infoText.textField.length * 100}, 7.5);
    songNameTween.cancel();
}

function changeSelection(change, silent, ?changeRemix)
{
    if (entries[curSelected][2] == "sound-gameover" && changeRemix) {
        voiceLine += 1;
        if (voiceLine > Std.int(entries[curSelected][4]) - 1) voiceLine = 0;
        if (voiceLine < 0) voiceLine = Std.int(entries[curSelected][4]) - 1;
        FlxG.sound.playMusic(Paths.sound("gameOverLines/" + entries[curSelected][0] + "/" + Std.string(voiceLine)));
    } else {
        if (change != 0) voiceLine = 0;

        if (entries[curSelected][3] == "true" && changeRemix) {
            changeVariant(change);
        } else if (entries[curSelected][3] == "false" && changeRemix) {
            return;
        }

        if (!changeRemix) {
            curVariant = 0;
        }

        if (opponentVoices != null) {
            opponentVoices.stop();
            opponentVoices.volume = 0;
            opponentVoices.kill();
        }
        if (voices != null) {
            voices.stop();
            voices.volume = 0;
            voices.kill();
        }

        paused = false;

        if (!changeRemix) {
            curSelected += change;
            if (curSelected > entries.length - 1) curSelected = 0;
            if (curSelected < 0) curSelected = entries.length - 1;
        }

        var internalName:String = entries[curSelected][0];
        internalName = StringTools.replace(internalName, "-instrumental", "");
        if (internalName.endsWith("-remixed")) internalName = StringTools.replace(internalName, "-remixed", "");

        infoText.x = internalName == "meet-maigo" ? 25 : 350;
        infoText.text = entries[curSelected][1];
        switch (entries[curSelected][5][curVariant])
        {
            case "remixed": infoText.text += " Remixed";
            case "remixedInstrumental": infoText.text += " Remixed Instrumental";
        }
        if (entries[curSelected][5][curVariant] == "instrumental") infoText.text += " Instrumental"; // the fucking switch case doesnt work on thriller-gen for some reason
        infoText.size = 44;

        if (silent) return;

        var playType = entries[curSelected][2];
        if (entries[curSelected][5][curVariant] == "instrumental" || entries[curSelected][5][curVariant] == "remixedInstrumental") playType = "inst";

        var variantName = entries[curSelected][5][curVariant];
        if (entries[curSelected][5][curVariant] == "instrumental" && internalName != "trinityEncoreUnfinished") variantName = "";
        if (entries[curSelected][5][curVariant] == "remixedInstrumental") variantName = "remixed";

        if (internalName == "trinityEncoreUnfinished" && variantName == "instrumental") {
            internalName = "trinityEncoreUnfinishedInstrumental";
            playType = "music";
            variantName = "";
        }

        switch (internalName)
        {
            case "terrorizerWIP": modDisclaimerText.text = "Unused track from Horizon's Edge";
            case "terrorizerDangenWIP": modDisclaimerText.text = "Unused track from Horizon's Edge\nMade by Dangen";
            case "tomodachiAsobi": modDisclaimerText.text = "Unused track from Executable Education 3D";
            default: modDisclaimerText.text = "";
        }

        modDisclaimerBacking.alpha = modDisclaimerText.text == "" ? 0.001 : 0.5;
        modDisclaimerBacking.setGraphicSize(820, modDisclaimerText.height);
        modDisclaimerBacking.screenCenter();
        modDisclaimerText.screenCenter();

        if (internalName == "meet-maigo") {
            songNameTween.active = false;
            infoText.x = 25;
        } else {
            restartTween();
        }

        switch (playType)
        {
            case "music":
                FlxG.sound.playMusic(Paths.music(internalName));

            case "full":
                FlxG.sound.playMusic(Paths.inst(internalName, variantName == "" ? null : variantName));
                voices = FlxG.sound.play(Paths.voices(internalName, "Player", variantName == "" ? null : variantName), 1);
                opponentVoices = FlxG.sound.play(Paths.voices(internalName, "Opponent", variantName == "" ? null : variantName), 1);
                opponentVoices.looped = true;
                voices.looped = true;

            case "inst":
                FlxG.sound.playMusic(Paths.inst(internalName, variantName == "" ? null : variantName));
                if (opponentVoices != null && opponentVoices.playing) opponentVoices.stop();
                if (voices != null && voices.playing) voices.stop();

            case "voices": // lol
                FlxG.sound.playMusic(Paths.voices(internalName, "Player", variantName == "" ? null : variantName));
                if (voices != null && voices.playing) voices.stop();
                opponentVoices = FlxG.sound.play(Paths.voices(internalName, "Opponent", variantName == "" ? null : variantName), 1);
                opponentVoices.looped = true;

            case "sound":
                FlxG.sound.playMusic(Paths.sound(internalName));

            case "sound-gameover":
                FlxG.sound.playMusic(Paths.sound("gameOverLines/" + internalName + "/" + Std.string(voiceLine)));
        }
    }
}

function pauseOrResume(resume:Bool = false) 
{
    paused = !paused;
	if (resume) {
        songNameTween.active = true;
		if (FlxG.sound.music != null) FlxG.sound.music.resume();
        if (voices != null) voices.resume();
        if (opponentVoices != null) opponentVoices.resume();
	} else {
        songNameTween.active = false;
		if (FlxG.sound.music != null) FlxG.sound.music.pause();
        if (voices != null) voices.pause();
        if (opponentVoices != null) opponentVoices.pause();
	}
}

function doButton(button:FlxSprite)
{
    button.alpha = 1;
    new FlxTimer().start(0.05, function(tmr) {
        button.alpha = 0.001;
    });
}

function changeVariant(change)
{
    curVariant += change;
    if (curVariant > entries[curSelected][5].length - 1) curVariant = 0;
    if (curVariant < 0) curVariant = entries[curSelected][5].length - 1;
}

function restartTween()
{
    infoText.x = 350;
    songNameTween.cancel();
    songNameTween = FlxTween.tween(infoText, {x: -infoText.width}, 5 * (infoText.textField.length / 30));
}

function onUpdate(e)
{
    customCursor.x = FlxG.mouse.x;
    customCursor.y = FlxG.mouse.y;

    if (!loaded) return;

    if (!maigo.currentlySpeaking) {
        if (!leaving && (FlxG.mouse.overlaps(toggleRemixesHitbox) && (entries[curSelected][3] == "true" || entries[curSelected][2] == "sound-gameover") || FlxG.mouse.overlaps(switchLeftHitbox) 
            || FlxG.mouse.overlaps(playPauseHitbox) || FlxG.mouse.overlaps(switchRightHitbox) || FlxG.mouse.overlaps(restartSongHitbox) || FlxG.mouse.overlaps(back))) {
            customCursor.animation.play("hover", true);
        } else if (!leaving && (!FlxG.mouse.overlaps(toggleRemixesHitbox) || !FlxG.mouse.overlaps(switchLeftHitbox) 
            || !FlxG.mouse.overlaps(playPauseHitbox) || !FlxG.mouse.overlaps(switchRightHitbox) || !FlxG.mouse.overlaps(restartSongHitbox) && !FlxG.mouse.overlaps(back))) {
            customCursor.animation.play("default");
        } else if (!loaded || leaving) {
            customCursor.animation.play("wait");
        }
    } else {
        customCursor.animation.play("default");
    }

    if (!infoText.isOnScreen()) restartTween();

    if (voices != null && opponentVoices != null && FlxG.sound.music.time > 5 && voices.playing && opponentVoices.playing)
	{
		var difference:Float = Math.abs(FlxG.sound.music.time - voices.time);
		if (difference >= 5 && !paused)
		{
			pauseOrResume(false);
			voices.time = FlxG.sound.music.time;
            opponentVoices.time = FlxG.sound.music.time;
			pauseOrResume(true);
		}
	}

    if (leaving || maigo.currentlySpeaking) return;

    if (FlxG.mouse.justPressed) { // i could probably do this better i am just very lazy. sorry
        if (FlxG.mouse.overlaps(toggleRemixesHitbox) && (entries[curSelected][3] == "true" || entries[curSelected][2] == "sound-gameover")) {
            changeSelection(1, false, true);
            doButton(toggleRemixesButton);
        } else if (FlxG.mouse.overlaps(switchLeftHitbox)) {
            changeSelection(-1, false, false);
            doButton(switchLeftButton);
        } else if (FlxG.mouse.overlaps(playPauseHitbox)) {
            pauseOrResume(paused);
            doButton(playPauseButton);
        } else if (FlxG.mouse.overlaps(switchRightHitbox)) {
            changeSelection(1, false, false);
            doButton(switchRightButton);
        } else if (FlxG.mouse.overlaps(restartSongHitbox)) {
            changeSelection(0, false, (entries[curSelected][3] == "true") ? true : false);
            doButton(restartSongButton);
        }
    }

    if (controls.BACK || FlxG.mouse.overlaps(back) && FlxG.mouse.justPressed) {
        songNameTween.cancel();
        back.alpha = 0.001;
        leaving = true;
        infoText.alpha = 0.001;
        overlay.animation.play("discmanZoom", true, true);
        modDisclaimerBacking.alpha = modDisclaimerText.alpha = 0;
        Main.fpsVar.defaultColor = 0xFFFFFFFF;
        if (curSelected != 0) FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.5);
        overlay.animation.finishCallback = function (wow)
        {
            if (curSelected != 0) {
                FlxTween.cancelTweensOf(FlxG.sound.music);
                FlxG.sound.music.volume = 0;
            }
            overlay.animation.finishCallback = null;
            pauseOrResume(true);
            if (curSelected != 0) {
                for (i in [FlxG.sound.music, voices, opponentVoices]) {
                    if (i != null) i.stop();
                    i.kill();
                }

                FlxG.sound.playMusic(Paths.music("meet-maigo"), 1);
            }
            FlxG.autoPause = true;
            saveSeenDialogues();
            MusicBeatState.switchState(new CustomState(), Paths.hscript("states/GalleryState"));
        }
    }
}

function onDestroy() {}

function saveSeenDialogues()
{
    for (i in maigoDialogues) {
        if (FlxG.save.data.seenMaigoDialogues.contains(i)) continue;
        FlxG.save.data.seenMaigoDialogues.push(i);
    }

    FlxG.save.flush();
}