import openfl.Lib;
import flixel.text.FlxText;
import flixel.text.FlxTextFormat;
import flixel.text.FlxTextFormatMarkerPair;
import flixel.addons.transition.FlxTransitionableState;
import states.CustomState;
import backend.Discord;
import backend.MusicBeatState;
import states.PlayState;

var creditsString:String = "

         \nSpringless    JasperCat
     \nSnowTheFox    DaPootisBird
            \nLandyRS       DylanZeMuffin\nSturm       ahlyess
          \ndRev    TheTrueSammu    [A2]\nCottonTheIdiot    Cr00L
              \n$Luigikid Gaming$    %Penkaru%\n#Kwite#    !Duncachi!\n&CommandoDev&    ^JoeDoughBoi^    /Joel/ >G>\n~AnarackWarriors~    *scrumbo_*    -FunkyBunny-
";

var sonicAnimation:FlxSprite;
var creditsText:FlxText;
var modName:FlxSprite;
var directorsText:FlxSprite;
var codersText:FlxSprite;

var voiceActorsText:FlxSprite;
var majinIcon:FlxSprite;
var xIcon:FlxSprite;
var rodentrapIcon:FlxSprite;
var lordXIcon:FlxSprite;

var playtestersText:FlxSprite;
var specialThanksText:FlxSprite;
var youreTooCool:FlxSprite;
var sparkles:FlxSprite;
var debug:Bool = false;
var legacySplashScreen:FlxSprite;
var pressSpace:FlxSprite;
var canSkip:Bool = true;
var skipPrompt:FlxSprite;
var inLegacySplash:Bool = false;

var maxWidth:Int;
var maxHeight:Int;

function onCreate()
{
    DiscordClient.changePresence("End Credits", null);

    maxWidth = Lib.application.window.stage.fullScreenWidth;
    maxHeight = Lib.application.window.stage.fullScreenHeight;

    if (CustomState.dataSelect) {
        FlxG.scaleMode = PlayState.getStageSizeScaleMode();
        resizeWindow(820, 720);
    }else{
        resizeWindow(maxWidth+1, maxHeight+1);
        Lib.application.window.borderless = true;
    }

    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;
    FlxG.sound.playMusic(Paths.music("youreTooCool"), 1);
    FlxG.sound.music.looped = false;

    sonicAnimation = new FlxSprite();
    sonicAnimation.frames = Paths.getSparrowAtlas("menus/endCredits/animation");
    sonicAnimation.animation.addByPrefix("intro", "intro", 15, false);
    sonicAnimation.animation.addByPrefix("loop", "loop", 8, true);
    sonicAnimation.animation.play("intro");
    sonicAnimation.screenCenter();
    sonicAnimation.scale.set(3.3, 3.3);
    game.add(sonicAnimation);

    sonicAnimation.animation.finishCallback = function () {
        sonicAnimation.animation.finishCallback = null;
        sonicAnimation.animation.play("loop", true);
    }

    modName = new FlxSprite(0, 750).loadGraphic(Paths.image("menus/endCredits/modName"));
    modName.scale.set(1.45, 1.45);
    modName.updateHitbox();
    modName.screenCenter(0x01);
    game.add(modName);

    directorsText = new FlxSprite(0, 835).loadGraphic(Paths.image("menus/endCredits/directors"));
    codersText = new FlxSprite(0, 970).loadGraphic(Paths.image("menus/endCredits/coders"));

    voiceActorsText = new FlxSprite(0, 1095).loadGraphic(Paths.image("menus/endCredits/voiceActors"));
    majinIcon = new FlxSprite(0, 1185).loadGraphic(Paths.image("menus/endCredits/vaIcons/majin"));
    xIcon = new FlxSprite(0, 1135).loadGraphic(Paths.image("menus/endCredits/vaIcons/2011x"));
    rodentrapIcon = new FlxSprite(0, 1135).loadGraphic(Paths.image("menus/endCredits/vaIcons/rodentrap"));
    lordXIcon = new FlxSprite(0, 1195).loadGraphic(Paths.image("menus/endCredits/vaIcons/lordX"));

    playtestersText = new FlxSprite(0, 1285).loadGraphic(Paths.image("menus/endCredits/playtesters"));
    specialThanksText = new FlxSprite(0, 1465).loadGraphic(Paths.image("menus/endCredits/specialThanks"));

    youreTooCool = new FlxSprite().loadGraphic(Paths.image("menus/endCredits/youreTooCool"));
    youreTooCool.screenCenter();
    youreTooCool.scale.set(3, 3);
    youreTooCool.alpha = 0.001;
    game.add(youreTooCool);

    sparkles = new FlxSprite();
    sparkles.frames = Paths.getSparrowAtlas("menus/title/sparkles");
    sparkles.animation.addByPrefix("sparkles", "sparkles", 30, true);
    sparkles.screenCenter();
    sparkles.alpha = 0.001;
    game.add(sparkles);

    for (i in [sonicAnimation, modName, youreTooCool, sparkles, majinIcon, xIcon, rodentrapIcon, lordXIcon]){
        i.antialiasing = false;
    }

    for (i in [directorsText, codersText, voiceActorsText, majinIcon, xIcon, rodentrapIcon, lordXIcon, playtestersText, specialThanksText]) {
        i.scale.set(1.75, 1.75);
        i.updateHitbox();
        i.screenCenter(0x01);
        game.add(i);
    }

    majinIcon.x = 580;
    xIcon.x = 670;
    rodentrapIcon.x = 300;
    lordXIcon.x = 350;

    creditsText = new FlxText(0, 650, FlxG.width, creditsString);
    creditsText.setFormat(Paths.font('sonic2HUD.ttf'), 40, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, 0xFF000000, false);
    creditsText.borderSize = 2;
    game.add(creditsText);

    legacySplashScreen = new FlxSprite();
    legacySplashScreen.frames = Paths.getSparrowAtlas("menus/endCredits/extrasSplashScreen");
    legacySplashScreen.animation.addByPrefix("loop", "loop", 12, true);
    legacySplashScreen.animation.play("loop");
    legacySplashScreen.screenCenter();
    legacySplashScreen.scale.set(3.25, 3.25);
    legacySplashScreen.alpha = 0.001;
    game.add(legacySplashScreen);

    pressSpace = new FlxSprite().loadGraphic(Paths.image("pressSpace"));
    pressSpace.screenCenter();
    pressSpace.visible = false;
    pressSpace.scale.set(3.2, 3.2);
    pressSpace.y = 300;
    pressSpace.alpha = 0.001;
    game.add(pressSpace);

    if (FlxG.save.data.seenCreditsRoll) {
        skipPrompt = new FlxSprite(660, 660).loadGraphic(Paths.image("menus/endCredits/skipCreditsRoll"));
        skipPrompt.scale.set(1.35, 1.35);
        skipPrompt.alpha = 0.001;
        game.add(skipPrompt);

        FlxTween.tween(skipPrompt, {alpha: 1}, 0.5);
    }

    var luigikidFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF00FC00), "$");
    var kwiteFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF20B420), "#");
    var duncachiFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF6BA0DE), "!");
    var penkaruFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFF84868), "%");
    var joeDoughBoiFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFB00020), "^");
    var commandoDevFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFA012E8), "&");
    var scrumboFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFDDE26D), "*");
    var anarackWarriorsFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFF80000), "~");
    var joelGFormatYellow = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFF8B400), "/");
    var joelGFormatBlue = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF105AE8), ">");
    var funkyBunnyFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFFD15E27), "-");

    creditsText.applyMarkup(creditsString, [luigikidFormat, kwiteFormat, duncachiFormat, 
    penkaruFormat, joeDoughBoiFormat, commandoDevFormat, scrumboFormat, anarackWarriorsFormat, joelGFormatYellow, joelGFormatBlue, funkyBunnyFormat]);

    new FlxTimer().start(3.24, function(tmr) {
        for (i in [modName, creditsText, directorsText, codersText, voiceActorsText, majinIcon, xIcon, rodentrapIcon, lordXIcon, playtestersText, specialThanksText]) {
            FlxTween.tween(i, {y: i.y - 1690}, 62.46);
        }

        if (skipPrompt != null) FlxTween.tween(skipPrompt, {alpha: 0.001}, 0.5);
    });

    new FlxTimer().start(4.36, function(tmr) {
        if (ClientPrefs.data.flashing) FlxG.camera.flash(0xFFFFFFFF, 1);
        FlxTween.tween(sonicAnimation, {alpha: 0.5}, ClientPrefs.data.flashing ? 0.000001 : 1);
    });

    new FlxTimer().start(65.46, function(tmr) {
        canSkip = false;
        FlxTween.tween(sonicAnimation, {alpha: 0}, 0.75);
    });

    new FlxTimer().start(66.6, function(tmr) {
        tooCoolFlash();
    });

    new FlxTimer().start(73.702, function(tmr) {
        tooCoolFinish();
    });
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

function tooCoolFlash()
{
    sonicAnimation.visible = false;
    if (skipPrompt != null) skipPrompt.visible = false;
    if (ClientPrefs.data.flashing) FlxG.camera.flash(0xFFE8EA10, 1);
    canSkip = false;
    youreTooCool.alpha = 1;
    sparkles.alpha = 1;
    sparkles.animation.play("sparkles");

    new FlxTimer().start(2.6, function(tmr) {
        sparkles.alpha = 0.001;
    });

    new FlxTimer().start(7, function(tmr) {
        tooCoolFinish();
    });
}

function tooCoolFinish()
{
    FlxTween.tween(youreTooCool, {alpha: 0}, 1, {onComplete: function (twn) {
        if (!FlxG.save.data.seenCreditsRoll) {
            FlxG.save.data.seenCreditsRoll = true;
            FlxG.save.flush();
        }

        if (!FlxG.save.data.seenLegacySplash || debug) {
            new FlxTimer().start(0.5, function(tmr) {
                pressSpace.visible = !pressSpace.visible;
            }, 0);
            FlxTween.tween(legacySplashScreen, {alpha: 1}, 0.5, {onComplete: function (twn) {
                inLegacySplash = true;
            }});
            FlxTween.tween(pressSpace, {alpha: 1}, 0.5);
        } else {
            goToMainMenu();
        }
    }});
}

function onUpdate(e)
{
    if (FlxG.save.data.seenCreditsRoll && controls.ACCEPT && canSkip) {
        FlxG.sound.music.time = 66540;
        for (i in [modName, creditsText, directorsText, codersText, voiceActorsText, majinIcon, xIcon, rodentrapIcon, lordXIcon, playtestersText, specialThanksText, sonicAnimation]) {
            FlxTween.cancelTweensOf(i);
            i.visible = false;
        }

        FlxTimer.globalManager.forEach(function(tmr:FlxTimer) if(!tmr.finished) tmr.active = false);
        tooCoolFlash();
    }

    if (!inLegacySplash) return;

    if (controls.BACK || controls.ACCEPT) {
        FlxG.sound.play(Paths.sound("confirmMenu"));
        new FlxTimer().start(1, function(tmr) {
            FlxTween.tween(pressSpace, {alpha: 0}, 0.5);
            FlxTween.tween(legacySplashScreen, {alpha: 0}, 0.5, {onComplete: function (twn) {
                if (!FlxG.save.data.seenLegacySplash) {
                    FlxG.save.data.seenLegacySplash = true;
                    FlxG.save.flush();
                }
                goToMainMenu();
            }});
        });
    }
}

function goToMainMenu()
{
    if (CustomState.dataSelect) {
        FlxG.sound.playMusic(Paths.music("freakyMenu"), 1);
        FlxG.sound.music.looped = true;
        Lib.application.window.borderless = false;
    } else {
        FlxG.scaleMode = PlayState.getStageSizeScaleMode();
        //resizeWindow(1280, 720);
        FlxG.resizeGame(1280, 720);
        FlxG.sound.music = null;
    }

    var returnMenu:String = !FlxG.save.data.seenPostCredits ? "states/PostCreditsState" : "states/MainMenuState";


    MusicBeatState.switchState(new CustomState(), Paths.hscript(CustomState.dataSelect ? "states/CreditsState" : returnMenu));
    CustomState.dataSelect = false;
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