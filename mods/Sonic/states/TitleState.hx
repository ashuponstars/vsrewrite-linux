import backend.ClientPrefs;
import backend.Discord;
import backend.CoolUtil;
import backend.MusicBeatState;
import states.PlayState;
import states.FlashingState;
import openfl.Lib;
import flixel.addons.transition.FlxTransitionableState;
import backend.Controls;
import hxvlc.flixel.FlxVideoSprite;

// a lot of these variables may not be needed tbh
var curPhase:Int = 0; // 0 - sega | 1 - video | 2 - sonic
var introAnim:FlxSprite;
var ring:FlxSprite;
var sonic:FlxSprite;
var arm:FlxSprite;
var logo:FlxSprite;
var sparkles:FlxSprite;
var pressSpace:FlxSprite;

var introVideo:FlxVideoSprite;
var canSkipVideo:Bool = false;

var sega:FlxSprite;
var canEnter:Bool = false;
var canSkipSega:Bool = true;
var skippedIntro:Bool = false;
var skippedVideo:Bool = false;
var canSkipIntro:Bool = false;
var introSound:FlxSound;
var inIntro:Bool = false;

function onCreate()
{
    Paths.clearStoredMemory();
    FlxG.save.bind('funkin', CoolUtil.getSavePath());
    ClientPrefs.loadPrefs();
    DiscordClient.changePresence("Title Screen", null);

    FlxG.scaleMode = PlayState.getStageSizeScaleMode();
    resizeWindow(820, 720);

    FlxG.fixedTimestep = false;
    FlxG.game.focusLostFramerate = 60;
    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;
    persistentUpdate = persistentDraw = true;

    if (FlxG.save.data.beatenTG == null) {
        FlxG.save.data.beatenTG = false;
        FlxG.save.flush();
    }
    if (FlxG.save.data.beatenTrinity == null) {
        FlxG.save.data.beatenTrinity = false;
        FlxG.save.flush();
    }
    if (FlxG.save.data.seenLegacySplash == null) {
        FlxG.save.data.seenLegacySplash = false;
        FlxG.save.flush();
    }
    if (FlxG.save.data.seenCreditsRoll == null) {
        FlxG.save.data.seenCreditsRoll = false;
        FlxG.save.flush();
    }
    if (FlxG.save.data.seenMaigoIntroduction == null) {
        FlxG.save.data.seenMaigoIntroduction = false;
        FlxG.save.flush();
    }
    if (FlxG.save.data.seenPostCredits == null) {
        FlxG.save.data.seenPostCredits = false;
        FlxG.save.flush();
    }
    if (FlxG.save.data.seenMaigoDialogues == null) {
        FlxG.save.data.seenMaigoDialogues = [];
        FlxG.save.flush();
    }

    if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;
        MusicBeatState.switchState(new CustomState(), Paths.hscript("states/FlashingState"));
        return;
    }

    introAnim = new FlxSprite();
    introAnim.frames = Paths.getSparrowAtlas("menus/title/intro");
    introAnim.animation.addByPrefix("intro", "intro", 30, false);
    introAnim.screenCenter();

    ring = new FlxSprite(250, 207.5).loadGraphic(Paths.image("menus/title/ring"));
    ring.alpha = 0.001;

    sonic = new FlxSprite(387, 239.5).loadGraphic(Paths.image("menus/title/sonic"));
    sonic.alpha = 0.001;

    arm = new FlxSprite();
    arm.frames = Paths.getSparrowAtlas("menus/title/arm");
    arm.animation.addByPrefix("arm", "arm", 15, false);
    arm.screenCenter();
    arm.alpha = 0.001;

    logo = new FlxSprite(382, 506.5).loadGraphic(Paths.image("menus/title/logo"));
    logo.alpha = 0.001;

    sparkles = new FlxSprite();
    sparkles.frames = Paths.getSparrowAtlas("menus/title/sparkles");
    sparkles.animation.addByPrefix("sparkles", "sparkles", 30, true);
    sparkles.screenCenter();
    sparkles.y += 230;
    sparkles.alpha = 0.001;

    pressSpace = new FlxSprite().loadGraphic(Paths.image("pressSpace"));
    pressSpace.screenCenter();
    pressSpace.visible = false;

    introVideo = new FlxVideoSprite();
	introVideo.load(Paths.video('intro'));
    introVideo.alpha = 0.001;
    game.add(introVideo);

    sega = new FlxSprite();
    sega.frames = Paths.getSparrowAtlas("menus/title/sega");
    sega.animation.addByPrefix("sega", "sega", 12, false);
    sega.animation.addByIndices("loop", "sega", [20, 21, 22, 23, 24], "", 12, true);
    sega.screenCenter();

    for (i in [introAnim, ring, sonic, arm, logo, pressSpace, sparkles, sega]) {
        i.scale.set(i == sparkles ? 1.5 : 3.5, i == sparkles ? 1.5 : 3.5);
        game.add(i);
    }

    introAnim.animation.finishCallback = function (fin)
    {
        setupSonic();
    }

    introSound = FlxG.sound.play(Paths.sound("title"), 0); // sega! :huggywuggy:
    introSound.pause();

    sega.animation.finishCallback = function (scream)
    {
        sega.animation.finishCallback = null;
        sega.animation.play("loop", true);
    }

    new FlxTimer().start(1, function(tmr) {
        sega.animation.play("sega");

        new FlxTimer().start(2.25, function(tmr) {
            if (curPhase == 0) {
                canSkipSega = false; 
                FlxG.sound.play(Paths.sound("segaScream"));
            }
        });
    });

    new FlxTimer().start(4.75, function(tmr) {
        if (sega.alpha < 1) return;
        FlxTween.tween(sega, {alpha: 0.001}, 0.5);

        new FlxTimer().start(2, function(tmr) {
            startVideo();
        });
    });
}

function startVideo()
{
    new FlxTimer().start(0.001, function(tmr) {
        curPhase = 1;
    });

    FlxTween.color(introVideo, 0.3, 0x000000FF, 0xFFFFFFFF);
    introVideo.alpha = 0.001;
    FlxTween.tween(introVideo, {alpha: 1}, 0.3);
    introVideo.play();
    introVideo.bitmap.onPlaying.add(function () {
        canSkipVideo = true;
    });

    introVideo.bitmap.onEndReached.add(function (){
        if (skippedVideo) return;
        introVideo.pause();
        FlxTween.color(introVideo, 0.15, 0xFFFFFFFF, 0x000000FF);
        FlxTween.tween(introVideo, {alpha: 0.001}, 0.3);
        new FlxTimer().start(0.8, function(tmr) {
            startIntro();
        });
    });
}

function setupSonic()
{
    introAnim.animation.finishCallback = null;
    introAnim.alpha = 0.001;
    for (i in [ring, sonic, arm, logo]) i.alpha = 1;

    new FlxTimer().start(2, function(tmr) {
        arm.animation.play("arm", true);
    }, 0);

    new FlxTimer().start(0.35, function(tmr) {
        pressSpace.visible = !pressSpace.visible;
    }, 0);
}

function startIntro()
{
    if (skippedIntro) return;

    inIntro = true;

    new FlxTimer().start(0.001, function(tmr) {
        curPhase = 2;
        canSkipIntro = true;
    });

    introSound.play(true);
    introSound.volume = 1;
    new FlxTimer().start(1.05, function(tmr) {
        introAnim.animation.play("intro");
    });

    new FlxTimer().start(5, function(tmr) {
        if (skippedIntro) return;
        FlxG.camera.fade(0xFFFFFFFF, 0.3, false);
    });

    new FlxTimer().start(6.5, function(tmr) {
        if (skippedIntro) return;
        canSkipIntro = false;
        canEnter = true;
        FlxG.camera.fade(0xFFFFFFFF, 0.3, true);
        sparkles.alpha = 1;
        sparkles.animation.play("sparkles");
    });

    new FlxTimer().start(8.5, function(tmr) {
        if (skippedIntro) return;
        sparkles.alpha = 0.001;
    });
}

function onUpdate(e)
{
    FlxG.mouse.visible = false;

    if (inIntro) introSound.volume = 1;
    if (introVideo != null && introVideo.alpha >= 0.001) introVideo.screenCenter();

    if (canSkipSega && controls.ACCEPT && curPhase == 0) {
        canSkipSega = false;
        FlxTween.color(sega, 0.15, 0xFFFFFFFF, 0x000000FF);
        FlxTween.tween(sega, {alpha: 0.001}, 0.3);
        new FlxTimer().start(0.5, function(tmr) {
            startVideo();
        });
    }

    if (canSkipVideo && controls.ACCEPT && curPhase == 1 && introVideo.bitmap.isPlaying) {
        canSkipVideo = false;
        introVideo.pause();
        FlxTween.color(introVideo, 0.15, 0xFFFFFFFF, 0x000000FF);
        FlxTween.tween(introVideo, {alpha: 0.001}, 0.3);
        new FlxTimer().start(0.3, function(tmr) {
            skippedVideo = true;
            startIntro();
        });
    }

    if (!skippedIntro && controls.ACCEPT && curPhase == 2 && canSkipIntro) {
        skippedIntro = true;
        canSkipIntro = false;
        introAnim.animation.finishCallback = null;
        introSound.play(true, 6280);
        introSound.volume = 1;
        new FlxTimer().start(0.001, function(tmr) {
            canEnter = true;
        });
        setupSonic();
        FlxG.camera.fade(0xFFFFFFFF, 0.3, true);
        sparkles.alpha = 1;
        sparkles.animation.play("sparkles");
        new FlxTimer().start(2, function(tmr) {
            sparkles.alpha = 0.001;
        });
    }

    if (canEnter && controls.ACCEPT) {
        canEnter = false;
        FlxG.sound.play(Paths.sound("confirmMenu"));
        new FlxTimer().start(0.25, function(tmr) {
            for (i in [ring, sonic, arm, logo, sparkles, pressSpace]) if (i.alpha == 1) FlxTween.color(i, 0.3, 0xFFFFFFFF, 0xFF0000FF);
            FlxG.camera.fade(0xFF000000, 0.5);
            new FlxTimer().start(0.55, function(tmr) {
                MusicBeatState.switchState(new CustomState(), Paths.hscript("states/MainMenuState"));
            });
        });
    }
}

function resizeWindow(width:Int = 820, height:Int = 720) // i tried to make this a global function in scripts but the compiler wouldnt stop bitching
{
    FlxG.resizeWindow(width, height);
    FlxG.resizeGame(width, height);
    var resolutionX = Math.ceil(Lib.current.stage.window.display.currentMode.width * Lib.current.stage.window.scale);
    var resolutionY = Math.ceil(Lib.current.stage.window.display.currentMode.height * Lib.current.stage.window.scale);
    Lib.application.window.x = (resolutionX - Lib.application.window.width) / 2;
    Lib.application.window.y = (resolutionY - Lib.application.window.height) / 2;
}

function onDestroy() {} // this is needed or it will crash on state switch/reset. sscript is so fucking bad