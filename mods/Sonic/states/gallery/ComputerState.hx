// WARNING: This shit is genuinely held together with duct tape and prayers. Im not even kidding this code is so fucking ass.

import backend.Controls;
import backend.Discord;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;
import hxvlc.flixel.FlxVideoSprite;
import objects.Bar;
import objects.MaigoSpeaker;
import Std;
import String;

var camGame:FlxCamera;
var underlay:FlxSprite;
var desktop:FlxSprite;
var overlay:FlxSprite;
var leaving:Bool = false;
var windowsSound:FlxSound;
var customCursor:FlxSprite;
var curPhase:Int = 0; // 0 - desktop, 1 - folder, 2 - image/video viewer, 3 - biography viewer
var window:FlxSprite;
var windowScrollBar:FlxSprite;
var windowSlider:FlxSprite;
var windowTitle:FlxText;
var windowImage:FlxSprite;
var windowCamera:FlxCamera;
var cursorCamera:FlxCamera;
var closeHitbox:FlxSprite;
var mouseLocked:Bool = false; // if mouse is currently held on scroll bar
var curFolder:String = ""; // current opened
var curSubFolder:Array; // current opened subfolder
var curRows:Int = 1; // all rows in a folder
var curRowsScroll:Int = 0; // rows created after scrolling is enabled
var windowSliderMinMax:Array<Float> = [170, 580]; // minimum and maximum y values of the slider
var windowVideo:FlxVideoSprite;
var videoPaused:Bool = false; // if video is PAUSED
var videoWasPaused:Bool = false; // if video was PAUSED before grabbing playhead
var videoReset:Bool = false; // video reset to starting position
var videoOver:Bool = false; // if video has ENDED
var videoPercent:Float = 0; // percentage of video completed
var windowPauseButton:FlxSprite;
var windowPreviousButton:FlxSprite;
var windowNextButton:FlxSprite;
var windowTimeBar:Bar;
var windowPlayhead:FlxSprite;
var windowBioText:FlxText;
var windowDebutText:FlxText;
var windowUpButton:FlxSprite;
var windowDownButton:FlxSprite;
var sliderMult:Int = 0;
var curApp:String = "";
var cursorAnimOverride:Bool = false;
var filesGroup:Dynamic;

var maigo:MaigoSpeaker;
var maigoDialogues:Array = [];
var descriptionText:FlxText;
var imageFolder:String = "";
var pastWindowScroll:Float = 0;

var characterBiosArray:Array = [ // Display name, file type, render name
    ["Sonic", "text", "sonic",],
    ["Majin", "text", "majin"],
    ["2011 X", "text", "2011X"],
    ["Lord X", "text", "lordX"],
    ["Maigo", "text", "maigo"],
    ["The Vessels", "text", "victims"],
    ["Boyfriend", "text", "bf"]
];

var curBioVariants:Array<String> = [];
var curBioSelected:Int = 0;

var conceptsArray:Array = [ // other arrays follow a similar format. Display name, file type, image name
    ["Springless\nSketches", "folder", "springSketches"],
    ["Amigo", "image", "amigo.png"],
    ["Beta Sonic", "image", "betarewrite.png"],
    ["Beta\nDead Knuckles", "image", "dedKnuxBeta.png"],
    ["BF Model\nTouchups", "image", "bfModelBeforeAdjustments.png"],
    ["Chaotic Evil", "image", "buds-export-2.png"],
    ["CGI Style", "video", "cgistyle2.mp4"],
    ["Creepy\nConcept", "image", "oldCreepyform.png"],
    ["Diabolical\nConcept", "image", "diabolicalConcept.png"],
    ["Early Faker\nForm Concept", "image", "sonicEarlyConcept.png"],
    ["Early Rewrite\nDesign", "image", "rewriteEarlyDesign.png"],
    ["First Green\nHills Render", "image", "firsteverGHrender.png"],
    ["First Sonic\nRender", "image", "firsteverSonicRender.png"],
    ["First Sonic\nSprites", "image", "firstSonicSpritesEverDone.png"],
    ["Gallery\nConcept", "image", "galleryConcept.png"],
    ["Game Over\nConcept", "image", "gameOverConcept.png"],
    ["Sonic Game\nOver Test", "image", "gameoverFormTest.png"],
    ["GH Fog Test", "image", "ghFogTest.png"],
    ["Handshake", "video", "hand shake.mp4"],
    ["Head Spin", "video", "headspin02.mp4"],
    ["Hi, I'm Sonic!", "image", "firsteverDialogueConcept.png"],
    ["I AM GOD\nSketch", "image", "iamgodsceen sketch.png"],
    ["I AM GOD\nConcept", "image", "oldIamGod.png"],
    ["Kaibutsu", "image", "kaibutsu.png"],
    ["Kaibutsu\nConcepts", "image", "oldAggressiveForm.png"],
    ["Kyokai\nConcept", "image", "kyokaiConcept.png"],
    ["Kyokai\nDark Sprites", "image", "kyokaiDark.xml"],
    ["Kyokai Form\nConcept", "image", "kyokaiformConcept.png"],
    ["Kyokai Head\nTest", "image", "kyokaiHeadtest.xml"],
    ["Kyokai Head\nTest 2", "image", "kyokaiHeadWip.xml"],
    ["Kyokai Eye\nAnimations", "image", "kyokaiEyeAnim.xml"],
    ["Kyokai Rig\nTest", "image", "rigtest.xml"],
    ["Kyokai Rig\nTest 2", "image", "rigtest2.xml"],
    ["Kyokai Spin", "image", "kyokaiSpin.xml"],
    ["Legacy BF\nSketches", "image", "bfLegacySketches.png"],
    ["Legacy Game\nOver Unedited", "image", "legacygameoverunedited.png"],
    ["Let's Play\nA Game", "video", "lets-play-a-game.mp4"],
    ["LX Before\n& After", "image", "lxBeforeAndAfter.png"],
    ["Maigo Sketch", "image", "maigoSketch.png"],
    ["Main Cast", "image", "sonicMainCastConcept.png"],
    ["Trinity Intro\nStoryboard", "video", "majincutscene storyboard.mp4"],
    ["Old\nGallery Concept", "image", "oldGalleryScreen.png"],
    ["Old Midareta\nTest", "image", "earlyMidaretaTest.png"],
    ["Old\nMiles Death", "image", "oldMilesDeath.png"],
    ["Old\nSonic Pose", "image", "oldmodelPose.png"],
    ["Old\nSonic Render", "image", "oldmodelrender.png"],
    ["Old Rewrite", "image", "oldRewrite.png"],
    ["Old Rewrite\nForms", "image", "rewriteOldForms.png"],
    ["Peelout\nTest", "image", "peeloutTest.png"],
    ["Puppet\nKnuckles", "image", "puppet_knuckles_concept.png"],
    ["Puppet\nTails", "image", "puppet_tails_concept.png"],
    ["Resolution\nTest", "video", "resolution.mp4"],
    ["Rewrite\nRedesign", "image", "rewriteRedesignProcess.png"],
    ["Round 2\nPromo Concept", "image", "promoConceptRound2.png"],
    ["Round 2\nBF Sketch", "image", "round2BfPromo.png"],
    ["SA2\nSketches", "image", "sa2spritesSketch.png"],
    ["Scrapped\nTrinity Poster", "image", "scrappedTrinityEncorePoster.png"],
    ["Size\nComparison", "image", "sizecomparasion.png"],
    ["Sonic\nConcepts", "image", "currentSonic.png"],
    ["Sonic\n& Maigo", "image", "maigoAndsonic.png"],
    ["Sonic\nExpression", "image", "sonicIfSonicExpression.png"],
    ["Sonic Spin", "video", "full bd spin.mp4"],
    ["Sonic Stage\nRender", "image", "sonic-stage-test.png"],
    ["Sonic Stage\nTest", "image", "sonic stage test-export.png"],
    ["Sonic Test", "image", "blenderSonicTest.xml"],
    ["Sonic V2", "image", "oldModelProcess.png"],
    ["Sonic V3", "image", "newModelProcess.png"],
    ["Sonic V3\nRenders", "image", "v3beta.png"],
    ["Stylized\nSonic", "image", "stylizedSonic.png"],
    ["Stylized\nSonic 2", "image", "stylizedSonic2.png"],
    ["Thriller Gen\nPoses", "image", "thrillerGenPoses.png"],
    ["Trinity Sonic\nStoryboard", "video", "fullrewritestoryboard.mp4"],
    ["Unedited Error\nImage", "image", "uneditedErrorImage.png"],
    ["X & Majin", "image", "xandMajin.png"],
    ["Zombie Vessels\n(Canon)", "image", "zombieCanon.png"]
];

var promoRendersArray:Array = [
    ["Banner", "image", "banner.png"],
    ["Thriller Gen\nAlbum Cover", "image", "tgAlbumCover.png"],
    ["Trinity\nAlbum Cover", "image", "trinityAlbumCover.png"]
];

var jokeImageryArray:Array = [
    ["AH HELL NAH", "image", "awHellNaw.png"],
    ["Avengers\nAssemble", "image", "whyIsHeThere.png"],
    ["Freak VS\nRewrite", "video", "its_rewrover.mp4"],
    ["freakwrite", "image", "freakwrite.png"],
    ["hugwrite", "image", "hugwrite.png"],
    ["I AM GOOD", "video", "iamgood.mp4"],
    ["Rewrite\nDel Void", "image", "rewriteDelVoid.png"],
    ["Super Sonic", "image", "cursed.png"],
    ["leakers be\nleaking", "video", "snowLeaksTheModLikeAnIdiot.mp4"],
    ["why so\nserious", "image", "jonkler.png"],
    ["TENNA NO", "video", "tennaNOOO.mp4"]
];

var cutscenesArray:Array = [
    ["Trinity:\nIntro", "video", "majinCutscene.mp4"],
    ["Trinity:\n2011 X", "video", "xCutscene.mp4"],
    ["Trinity:\nFUSION", "video", "fusionCutscene.mp4"],
    ["Trinity:\nLord X", "video", "lordXCutscene.mp4"],
    ["Trinity (Legacy):\nIntro", "video", "trinityLegacyIntro.mp4"]
];

var videoArray:Array = [];
var springSketchFiles:Array = []; // empty because we add the files using a loop
var springSketchesArray:Array = ["springSketches", "Springless Sketches", "folder", 0, 0, springSketchFiles];
var curAssetsArray:Array = []; // used to cache current files in a folder
var apps:Array = [ // internal name, display name, icon, x, y, content array
    ["thisPC", "This PC", "thisPC", 90, 30, null],
    ["recycleBin", "Recycle Bin", "recycleBin", 90, 530, null],
    ["powerOff", "Power Off", "power", 600, 530, null],

    ["characterBios", "Character\nBiographies", "folder", 450, 30, characterBiosArray],
    ["concepts", "Concepts /\nOld Content", "folder", 600, 30, conceptsArray],
    ["promoRenders", "Promotional\nRenders", "folder", 450, 170, promoRendersArray],
    ["jokeImagery", "Joke Imagery", "folder", 600, 170, jokeImageryArray],
    ["cutscenes", "Video\nCutscenes", "folder", 600, 310, cutscenesArray]
];

function onCreate()
{
    Paths.clearUnusedMemory();

    camGame = initPsychCamera();

    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;

    DiscordClient.changePresence("Gallery - Desktop", null);

    FlxG.camera.bgColor = 00000000;
    FlxG.sound.music.volume = 1;

    underlay = new FlxSprite(0, 0).makeGraphic(1000, 1000, 0xFF050505);
    underlay.scale.set(100, 100);

    desktop = new FlxSprite().loadGraphic(Paths.image("menus/gallery/desktop/michaelsoftBinbows"));

    for (i in [underlay, desktop]) game.add(i);

    for (i in apps)
    {
        var icon = new FlxSprite(i[3], i[4]).loadGraphic(Paths.image("menus/gallery/desktop/icons/" + i[2]));
        icon.scale.set(2.5, 2.5);
        icon.updateHitbox();
        icon.alpha = 0.001;
        game.add(icon);

        var text = new FlxText(i[3] - 345, i[4] + 105, FlxG.width, i[1]);
        text.setFormat(Paths.font("windows-xp-tahoma.ttf"), 30, 0xFFFFFFFF, "center", FlxTextBorderStyle.SHADOW, 0xFF272B4F, false);
        text.borderSize = 1.5;
        text.alpha = 0.001;
        game.add(text);

        i.push([icon, text]);
    }

    overlay = new FlxSprite(0, 0);
    overlay.frames = Paths.getSparrowAtlas("menus/gallery/room");
    overlay.animation.addByPrefix("main", "room", 15, true);
    overlay.animation.addByPrefix("monitorZoom", "monitorZoom", 15, false);
    overlay.animation.play("monitorZoom", true, false, 6);

    for (i in ["windowsStartup", "windowsShutdown", "windowsClick"]) Paths.sound(i);

    new FlxTimer().start(0.75, function(tmr) {
        desktop.alpha = 1;
        new FlxTimer().start(0.5, function(tmr) {
            for (i in apps) for (o in i[6]) o.alpha = 1;
        });
        windowsSound = FlxG.sound.play(Paths.sound("windowsStartup"));
    });

    window = new FlxSprite().loadGraphic(Paths.image("menus/gallery/desktop/window"));
    window.screenCenter();
    Paths.image("menus/gallery/desktop/videoPlayer/videoPlayer");

    windowImage = new FlxSprite();
    windowImage.screenCenter();

    windowVideo = new FlxVideoSprite();
    windowVideo.screenCenter();
    windowVideo.scale.set(0.76, 0.76);

    windowBioText = new FlxText(135, 200, 300, "");
    windowBioText.setFormat(Paths.font("sonic2HUD.ttf"), 30, 0xFF000000, "center");

    windowUpButton = new FlxSprite(100, 125).loadGraphic(Paths.image("menus/gallery/desktop/arrow"));

    windowDownButton = new FlxSprite(100, 628).loadGraphic(Paths.image("menus/gallery/desktop/arrow"));
    windowDownButton.flipY = true;

    windowPauseButton = new FlxSprite(0, 598);
    windowPauseButton.frames = Paths.getSparrowAtlas("menus/gallery/desktop/videoPlayer/button");
    windowPauseButton.animation.addByPrefix("pause", "pause", 24, true);
    windowPauseButton.animation.addByPrefix("play", "play", 24, true);
    windowPauseButton.animation.play("pause");
    windowPauseButton.screenCenter(0x01);
    windowPauseButton.x -= 15;

    windowPreviousButton = new FlxSprite(windowPauseButton.x - 40, windowPauseButton.y + 9).loadGraphic(Paths.image("menus/gallery/desktop/videoPlayer/skip"));
    windowPreviousButton.flipX = true;
    windowNextButton = new FlxSprite(windowPauseButton.x + 62, windowPauseButton.y + 9).loadGraphic(Paths.image("menus/gallery/desktop/videoPlayer/skip"));

    windowTimeBar = new Bar(167, 580, 'menus/gallery/desktop/videoPlayer/timeBar', function() return videoPercent, 0, 1);
    windowTimeBar.setColors(0xFFFFFFFF, 0xFF61639E);
    for (i in [windowTimeBar.leftBar, windowTimeBar.rightBar]) i.scale.y += 1;

    windowPlayhead = new FlxSprite(0, 578).loadGraphic(Paths.image("menus/gallery/desktop/videoPlayer/playhead"));

    windowScrollBar = new FlxSprite(645, 280).loadGraphic(Paths.image("menus/gallery/desktop/slider"));
    windowSlider = new FlxSprite(633, windowSliderMinMax[0]).loadGraphic(Paths.image("menus/gallery/desktop/scrollSelect"));

    for (i in [window, windowPauseButton, windowPreviousButton, windowNextButton, windowScrollBar, windowSlider, windowPlayhead, windowUpButton, windowDownButton]) i.scale.set(2, 2);
    for (i in [windowSlider, windowPauseButton, windowPreviousButton, windowNextButton, windowPlayhead, windowUpButton, windowDownButton]) i.updateHitbox();

    windowTitle = new FlxText(window.x - 120, window.y - 117, FlxG.width, "hello!");
    windowTitle.setFormat(Paths.font("windows-xp-tahoma.ttf"), 42, 0xFFFFFFFF, "left", FlxTextBorderStyle.SHADOW, 0xFF272B4F, false);
    windowTitle.borderSize = 1.5;
    windowTitle.bold = true;
    windowTitle.alpha = 0.001;

    windowCamera = new FlxCamera(144, 161, 498, 452);
    cursorCamera = new FlxCamera(0, 0, 820, 720);

    for (i in [windowCamera, cursorCamera]) {
        i.bgColor = 0x00000000;
        i.pixelPerfectRender = true;
        FlxG.cameras.add(i, false);
    }

    windowBioText.camera = windowCamera;

    closeHitbox = new FlxSprite(630, 111).makeGraphic(42, 42, 0xFFFFFFFF);

    maigo = new MaigoSpeaker();
    maigoDialogues = FlxG.save.data.seenMaigoDialogues;

    descriptionText = new FlxText(0, 618, FlxG.width, "", 40);
    descriptionText.setFormat(Paths.font("sonic2HUD.ttf"), 40, 0xFFFFFFFF, "center", FlxTextBorderStyle.SHADOW, 0xFF000000);
    descriptionText.borderSize = 2;

    customCursor = new FlxSprite(-100, -100); // this really sucks
    customCursor.frames = Paths.getSparrowAtlas("cursor");
    customCursor.animation.addByPrefix("default", "default", 24, false);
    customCursor.animation.addByPrefix("wait", "wait", 24, false);
    customCursor.animation.addByPrefix("hover", "hover", 24, false);
    customCursor.animation.play("default");
    customCursor.scale.set(1.5, 1.5);

    filesGroup = createGroup();
    filesGroup.camera = windowCamera;
    game.add(filesGroup);

    for (i in [customCursor, windowSlider, windowUpButton, windowDownButton, maigo, descriptionText]) i.camera = cursorCamera;

    desktop.alpha = window.alpha = windowImage.alpha =
    windowVideo.alpha = windowPauseButton.alpha = windowPreviousButton.alpha =
    windowNextButton.alpha = windowScrollBar.alpha = windowSlider.alpha = 
    windowTimeBar.alpha = windowPlayhead.alpha = closeHitbox.alpha = 
    windowUpButton.alpha = windowDownButton.alpha = windowBioText.alpha = 0.001;

    for (i in [window, windowImage, windowVideo, windowUpButton, windowDownButton, windowBioText, windowPauseButton, windowPreviousButton, windowNextButton, 
    windowTimeBar, windowPlayhead, windowScrollBar, windowSlider, windowTitle, closeHitbox, overlay, maigo, descriptionText, customCursor]) game.add(i);

    for (i in [overlay, desktop]) {
        i.scale.set(i == desktop ? 3.6 : 3.5, 3.5);
        i.screenCenter();
    }

    CustomState.dataSelect = true;

    for (i in 1...11) springSketchFiles.push(["New Design\nSketches " + i, "image", "newDesignSketches" + i + ".png"]);
    for (i in 1...22) springSketchFiles.push(["Sketches " + i, "image", "springSketches" + i + ".png"]);
}

var overlappingApp:Bool = false;
var overlappingFile:Bool = false;
var overlappedApp:Array;
var overlappedFile:Array;

function clearImageFromMem(image)
{
    var actKey = StringTools.replace(image, ".xml", ".png");
    Paths.clearImageFromMemory(actKey);
}

function onUpdate(e)
{
    if (windowVideo != null && windowVideo.bitmap != null) videoPercent = (windowVideo.bitmap.time / windowVideo.bitmap.length);
    customCursor.x = FlxG.mouse.x;
    customCursor.y = FlxG.mouse.y;

    var overlaps = (overlappingApp || overlappingFile || 
    FlxG.mouse.overlaps(closeHitbox) && window.alpha == 1 && !maigo.currentlySpeaking || 
    FlxG.mouse.overlaps(windowPauseButton) && windowPauseButton.alpha == 1 ||
    FlxG.mouse.overlaps(windowPreviousButton) && windowPreviousButton.alpha == 1 ||
    FlxG.mouse.overlaps(windowNextButton) && windowNextButton.alpha == 1 ||
    FlxG.mouse.overlaps(windowUpButton) && windowUpButton.alpha == 1 ||
    FlxG.mouse.overlaps(windowDownButton) && windowDownButton.alpha == 1 ||
    FlxG.mouse.overlaps(filesGroup, windowCamera));

    if (!maigo.currentlySpeaking || !cursorAnimOverride) {
        if (!leaving && overlaps) {
            customCursor.animation.play("hover", true);
        } else if (!leaving && !overlaps) {
            customCursor.animation.play("default", true);
        } else if (leaving) {
            customCursor.animation.play("wait", true);
        }
    } else {
        customCursor.animation.play("default", true);
    }

    if (FlxG.mouse.justPressed && overlaps && !maigo.currentlySpeaking) FlxG.sound.play(Paths.sound("windowsClick"));

    windowPlayhead.x = windowTimeBar.barCenter - 5;

    switch (curPhase)
    {
        case 0:
            if (leaving) return;
            
            if (FlxG.mouse.justPressed && overlappingApp) {
                if (overlappedApp[0] == "thisPC" || overlappedApp[0] == "recycleBin") return;
                openWindow(overlappedApp);
                curPhase = 1;
                return;
            }
            
            if (controls.BACK) powerOff();

            for (i in apps)
            {
                if (i[0] == "thisPC" || i[0] == "recycleBin") continue;
                if (FlxG.mouse.overlaps(i[6][0]) && i[6][0].alpha == 1) {
                    overlappingApp = true;
                    overlappedApp = i;
                    break;
                }

                overlappingApp = false;
                overlappedApp = null;
            }

        case 1: // this sucks
            sliderShit();

            if (FlxG.mouse.overlaps(closeHitbox) && FlxG.mouse.justPressed || controls.BACK) {
                if (curSubFolder == null) {
                    window.alpha = windowScrollBar.alpha = windowTitle.alpha = windowSlider.alpha = 0.001;
                    curPhase = 0;
                    clearCurAssetsArray();
                    videoArray = [];
                } else {
                    windowCamera.scroll.y = 0;
                    clearCurAssetsArray();
                    videoArray = [];
                    openWindow(overlappedApp);
                    curSubFolder = null;
                }

                pastWindowScroll = 0;
                windowSlider.y = windowSliderMinMax[0];
                windowCamera.scroll.y = 0;
            }

            if (!overlappingFile && FlxG.mouse.justPressed) {
                for (i in curAssetsArray) {
                    if (i[2].isOnScreen(windowCamera) && FlxG.mouse.overlaps(i[2], windowCamera)) {
                        overlappingFile = true;
                        overlappedFile = i;
                        break;
                    }

                    overlappingFile = false;
                    overlappedFile = null;
                }
            }

            if (FlxG.mouse.justPressed && overlappingFile) {
                new FlxTimer().start(0.05, function(tmr) {
                    if (overlappedFile[1].text == "Springless\nSketches") {
                        windowCamera.scroll.y = 0;
                        windowSlider.y = windowSliderMinMax[0];
                        clearWindow();
                        curSubFolder = springSketchesArray;
                        openWindow(springSketchesArray);
                    } else {
                        openFile([overlappedFile[1].text, overlappedFile[3], overlappedFile[4]]);
                    }
                });
            }

        case 2:
            if (FlxG.mouse.overlaps(closeHitbox) && FlxG.mouse.justPressed || controls.BACK) {
                curPhase = 1;
                clearWindow();
                openWindow(curSubFolder == null ? overlappedApp : curSubFolder);
                windowImage.loadGraphic(Paths.image("credits/placeholder")); // what one is your happy
                clearImageFromMem("menus/gallery/galleryImages/" + imageFolder + "/" + overlappedFile[3]);
                maigo.backing.alpha = 0.001;
                descriptionText.text = "";
                return;
            }

            if (windowVideo.alpha == 1) {
                if (FlxG.mouse.overlaps(windowPauseButton) && FlxG.mouse.justPressed || controls.ACCEPT) {
                    if (!videoOver) {
                        videoPaused = !videoPaused;
                        videoWasPaused = !videoWasPaused;
                        windowPauseButton.animation.play(videoPaused ? "play" : "pause");
                        windowVideo.togglePaused();
                    } else {
                        videoPaused = false;
                        windowVideo.bitmap.time = 0;
                        windowVideo.stop();
                        windowVideo.resume();
                        windowVideo.play();
                        windowPauseButton.animation.play("pause");
                        videoOver = false;
                    }
                }

                if (FlxG.mouse.overlaps(windowPreviousButton) && FlxG.mouse.justPressed) {
                    clearWindow();
                    var val = Std.parseInt(overlappedFile[4]) - 1;
                    if (val < 0) val = videoArray.length - 1;
                    overlappedFile[4] = val;
                    openFile([videoArray[val][0], videoArray[val][1], videoArray[val][2]]);
                }

                if (FlxG.mouse.overlaps(windowNextButton) && FlxG.mouse.justPressed) {
                    clearWindow();
                    var val = Std.parseInt(overlappedFile[4]) + 1;
                    if (val > videoArray.length - 1) val = 0;
                    overlappedFile[4] = val;
                    openFile([videoArray[val][0], videoArray[val][1], videoArray[val][2]]);
                }

            if (windowPlayhead.alpha == 1 && (FlxG.mouse.overlaps(windowPlayhead) || mouseLocked))
                if (FlxG.mouse.pressed) mouseLocked = true;

            if (mouseLocked)
            {
                if (!videoPaused) {
                    videoWasPaused = videoPaused;
                    videoPaused = true;
                    windowPauseButton.animation.play("play");
                    windowVideo.pause();
                    videoReset = false;
                }

                windowPlayhead.x = (FlxG.mouse.getPosition().x - windowPlayhead.width / 2);
                if (windowPlayhead.x > 165 && windowPlayhead.x < 635) 
                    windowVideo.bitmap.time = addIntToInt64(windowVideo.bitmap.time, Std.int(FlxG.mouse.deltaX * (windowVideo.bitmap.length / 466)));

                if (windowPlayhead.x < 165) {
                    windowVideo.bitmap.time = 0;
                    if (!videoReset) {
                        windowVideo.stop();
                        windowVideo.play();
                        windowVideo.pause();
                        videoReset = true;
                    }
                }
                if (windowPlayhead.x >= 635) windowVideo.bitmap.time = windowVideo.bitmap.length;
            }

            if (FlxG.mouse.released && videoPaused && mouseLocked) {
                mouseLocked = false;
                if (!videoWasPaused) {
                    windowPauseButton.animation.play("pause");
                    windowVideo.resume();
                    videoPaused = false;
                    videoWasPaused = false;
                }
            }
        }

        case 3:
            if ((FlxG.mouse.overlaps(closeHitbox) && FlxG.mouse.justPressed || controls.BACK) && !maigo.currentlySpeaking) {
                curPhase = 1;
                clearWindow();
                windowCamera.scroll.y = 0;
                openWindow(curSubFolder == null ? overlappedApp : curSubFolder);
                return;
            }

            if ((FlxG.mouse.overlaps(windowDownButton) && FlxG.mouse.justPressed || controls.UI_DOWN_P) && windowDownButton.alpha == 1) curBioSelected += 1;
            if ((FlxG.mouse.overlaps(windowUpButton) && windowUpButton.alpha == 1 && FlxG.mouse.justPressed || controls.UI_UP_P) && windowUpButton.alpha == 1) curBioSelected -= 1;

            if (((FlxG.mouse.overlaps(windowUpButton) && FlxG.mouse.justPressed || controls.UI_UP_P) && windowUpButton.alpha == 1) 
                || ((FlxG.mouse.overlaps(windowDownButton) && FlxG.mouse.justPressed || controls.UI_DOWN_P)) && windowDownButton.alpha == 1) {
                if (curBioSelected > curBioVariants.length - 1) curBioSelected = 0;
                if (curBioSelected < 0) curBioSelected = curBioVariants.length - 1;

                loadCharacterBio(curBioVariants[curBioSelected], false);
            }

            sliderShit();
    }

    windowPlayhead.x = FlxMath.bound(windowPlayhead.x, 165, 635);
    windowSlider.y = FlxMath.bound(windowSlider.y, windowSliderMinMax[0], windowSliderMinMax[1]);
}

function sliderShit()
{
    if (sliderMult >= 24 && !mouseLocked) windowCamera.scroll.y -= FlxG.mouse.wheel * (curRows * 2.85);

    if (windowSlider.alpha == 1 && (FlxG.mouse.overlaps(windowSlider) || mouseLocked)) if (FlxG.mouse.pressed) mouseLocked = true;

    if (mouseLocked && FlxG.mouse.wheel == 0) {
        windowSlider.y = (FlxG.mouse.getPosition().y + 5 - windowSlider.height / 2);
        if (windowSlider.y > windowSliderMinMax[0] && windowSlider.y < windowSliderMinMax[1] || (windowSlider.y == windowSliderMinMax[0] && windowCamera.scroll.y != 0 
        || windowSlider.y == windowSliderMinMax[1] || windowCamera.scroll.y != windowCamera.maxScrollY)) windowCamera.scroll.y += (FlxG.mouse.deltaY * (curRowsScroll / 3.49));

        // main fix for scrolling being weird if you flick the slider back and forth in a small area
        if (windowSlider.y <= windowSliderMinMax[0]) windowCamera.scroll.y = 0;
        if (windowSlider.y >= windowSliderMinMax[1]) windowCamera.scroll.y = windowCamera.maxScrollY;
    }

    if (FlxG.mouse.wheel != 0) windowSlider.y -= (FlxG.mouse.wheel * 1050 / sliderMult);
    if (FlxG.mouse.released) mouseLocked = false;
}

function clearCurAssetsArray() // tried to make this a function that can clear any array passed through but it wouldnt fucking work for some reason???
{
    if (curAssetsArray.length == 0) return;

    for (i in curAssetsArray) {
        if (i == null) continue;
        for (o in i) {
            if (o == null || Std.isOfType(o, String)) continue;
            o.destroy();
        }
    }
    
    curAssetsArray = [];
}

function resizeWindow(mult:Float = 1, resizeSlider:Bool = true)
{
    if (mult != 1) pastWindowScroll = windowCamera.scroll.y;
    for (i in [window, windowScrollBar, windowSlider]) {
        if (!resizeSlider && i == windowSlider) continue;

        i.scale.set(2 * mult, 2 * mult);
    }

    closeHitbox.setGraphicSize(42 * mult, 42 * mult);

    windowCamera.width = 498 * mult;
    windowCamera.height = 452 * mult;

    if (mult != 1) {
        window.scale.y *= 1.022;
        windowCamera.height *= 1.022;
    }

    // hardcoding this because fuck me haha
    if (mult == 1.175) {
        windowCamera.setPosition(96, 121);
        closeHitbox.setPosition(672, 66);
        windowTitle.setPosition(110, 62);
        if (resizeSlider) {
            windowSliderMinMax = [130, 618];
            windowSlider.setPosition(674, windowSliderMinMax[0]);
            windowScrollBar.setPosition(689, 280);
        }
        windowTitle.size = 54;
    } else if (mult == 1) {
        windowCamera.setPosition(144, 161);
        closeHitbox.setPosition(630, 111);
        windowTitle.setPosition(154, 113.5);
        if (resizeSlider) {
            windowSliderMinMax = [170, 580];
            windowSlider.setPosition(633, windowSliderMinMax[0]);
        }
        windowScrollBar.setPosition(645, 280);
        windowTitle.size = 42;
        if (curSubFolder == null) windowCamera.scroll.y = pastWindowScroll;
    }

    windowBioText.fieldWidth = windowCamera.width;
    windowSlider.updateHitbox();
}

function loadCharacterBio(file:Array, reloadBioVariants:Bool = true)
{
    curPhase = 3;
    resizeWindow(1.175, true);

    windowTitle.text = curFolder + " - " + StringTools.replace(file[0], "\n", " ");
    windowImage.loadGraphic(Paths.image("menus/gallery/galleryImages/characterBios/" + file[1]));
    windowImage.alpha = 1;
    windowImage.antialiasing = false;
    windowImage.camera = windowCamera;

    sliderMult = 24;

    windowBioText.alpha = 1;
    windowBioText.setPosition(7, 460);

    windowCamera.scroll.y = 0;
    windowCamera.minScrollY = 0;

    var seenDialogue:Bool = false;

    for (i in maigoDialogues) {
        if (i == file[1]) {
            seenDialogue = true;
            break;
        }
    }

    switch (file[1]) // INFORMATION
    {
        case "sonic":
            curRows = 11;
            curRowsScroll = 2.55;
            windowCamera.maxScrollY = 900;
            windowBioText.text = "The anomaly's vessel. Initially acting similar to the original Sonic the Hedgehog, this entity carries an eccentric and manipulative nature, appearing friendly to the naked eye. Originally manifesting in the 90's via a scam program that would supposedly allow people to communicate with God, Sonic claimed many victims and took various forms to make their souls a part of the anomaly.\n\nDEBUT: VS REWRITE (2022)\nALIAS: Rewrite";

        case "sonic-midareta":
            curRows = 8;
            curRowsScroll = 1.85;
            windowCamera.maxScrollY = 800;
            windowBioText.text = "Occurs mostly when Sonic possesses only 2 rings. In this state, they're in-between no self-awareness and full self-awareness, which results in instability and inexpressibly 'feeling gray'. This is a very unstable state that affects not only Sonic, but their surroundings too.\n\nDEBUT: SONIC.EXE REWRITE (2024)\nALIAS: Rewrite";

        case "sonic-wurugashikoi":
            curRows = 9;
            curRowsScroll = 2.25;
            windowCamera.maxScrollY = 850;
            windowBioText.text = "In this form, Sonic is fully self-aware of itself, they can bend the anomaly to their will without limits and even affect our dimension. They no longer try mimicking the original Sonic mannerisms and instead take on a more eccentric and confident posture, which reflects their narcissist and sadistic nature a lot more.\n\nDEBUT: VS REWRITE (2022)\nALIAS: Rewrite";

        case "sonic-kyokai":
            curRows = 14;
            curRowsScroll = 3.3;
            windowCamera.maxScrollY = 1000;
            windowBioText.y = 620;
            windowBioText.text = "Sonic's true nature leaks through to the point where their model starts shaping itself closer to their 'true form'. However, it cannot be conceived in 3D, so the model just collapses in on itself, giving Sonic a broken mesh appearance. The rings also fuse into his body, and he becomes massively taller.\n\nDEBUT: VS REWRITE: ROUND 2 (2025)\nALIAS: Rewrite";

        case "majin":
            windowBioText.text = "Born from an inside joke during the development of Sonic CD, this macabre figure has grown in popularity and has sneakily made it's way into the EXE community. He enjoys playing games with other Mazins, but is gullible and tends to easily get distracted.\n\nDEBUT: SONIC CD (1993)\nALIAS: Majin Sonic, Mazin";
            curRows = 8;
            curRowsScroll = 2;
            windowCamera.maxScrollY = 810;

        case "majin-fusion":
            curRows = 4;
            curRowsScroll = 0.9;
            windowBioText.x = 3;
            windowCamera.maxScrollY = 670;
            windowBioText.text = "While Sonic rapidly changes forms during the events of Trinity, they quickly turn the Majin & 2011 X models into vessels, fusing them together for your amusement.\n\nDEBUT: VS REWRITE (2022)";

        case "2011X":
            windowBioText.text = "Formed from the VOID, this entity enjoys playing twisted games with it's 'friends'. Taking an interest in Sonic the Hedgehog, it had utilized it's own Sonic game in order to lure in new 'friends' until 2011, where it's game was dumped to the internet.\n\nDEBUT: SONIC 2011 (2023)\nALIAS: X, SONIC.EXE";
            curRows = 8;
            curRowsScroll = 2;
            windowCamera.maxScrollY = 810;

        case "2011X-rodentrap":
            windowBioText.text = "X takes on the full appearance of Sonic the Hedgehog, using this form to lure in unsuspecting players.\n\nDEBUT: FNF RODENTRAP / SONIC LEGACY (2024)\nALIAS: Sonic the Hedgehog";
            curRows = 5;
            curRowsScroll = 1.22;
            windowCamera.maxScrollY = 710;

        case "lordX":
            windowBioText.y = 480;
            windowBioText.text = "A future incarnation of X, taking place long after the events of SONIC 2011. Armed with a new level of experience and feedback from it's so-called 'friends', it intends to create an experience that will satisfy not only itself, but them. As long as his 'friends' feed it, it'll continue to create more games until it achieves his goal.\n\nDEBUT: SONIC PC PORT (2020)\nALIAS: X, SONIC.EXE, Old Friend";
            curRows = 10;
            curRowsScroll = 2.5;
            windowCamera.maxScrollY = 890;

        case "lordX-internal":
            windowBioText.y = 680;
            curRows = 16.7;
            curRowsScroll = 4.1;
            windowCamera.maxScrollY = 1100;
            windowBioText.text = "A future incarnation of X, taking place long after the events of SONIC 2011. Armed with a new level of experience and feedback from it's so-called 'friends', it intends to create an experience that will satisfy not only itself, but them. As long as his 'friends' feed it, it'll continue to create more games until it achieves his goal.\n\nDEBUT: SONIC PC PORT (2020)\nALIAS: X, SONIC.EXE, Old Friend";

        case "victims", "victims-dead":
            curRows = 18.5;
            curRowsScroll = 4.6;
            windowCamera.maxScrollY = 1160;
            windowBioText.y = 470;
            windowBioText.text = "The three rings that Sonic wears on it's body are the in-game representation of their victims' souls: Miles, Ekiduna, and IV0, respectively. The characters serve as vessels for people's souls who died during a playthrough of Sonic's game and are now bound to the anomaly forever. They take on the role of a character with each boot-up and progressively lose the memory of who they were in life, until all that's left is the character. Miles is the scared one, being constantly picked on by Sonic and the others, Ekiduna is a thief and a crook who's always trying to come out on top, and IV0 is a twisted alchemist who uses his emotional intelligence to his advantage.\n\nDEBUT: SONIC.EXE REWRITE (2024)\nALIAS: Miles, Ekiduna, IV0";

        case "maigo":
            curRows = 6;
            curRowsScroll = 1.4;
            windowCamera.maxScrollY = 740;
            windowBioText.x = 3;
            windowBioText.text = "One of Sonic's oldest friends! Maigo is of relaxed and cheerful nature, always seeming excited about what will happen next. He holds deep respect and admiration for 'Mr. Sonic' as he calls them. That's all there is to this little fella!\n\nDEBUT: SONIC.EXE REWRITE (2024)";

            if (!seenDialogue) {
                seenDialogue = true;
                maigo.currentlySpeaking = true;
                new FlxTimer().start(0.35, function(tmr) {
                    for (i in [FlxG.sound.music, windowsSound]) FlxTween.tween(i, {volume: 0.3}, 0.2);
                    maigo.startDialogue([
                        ["Who am I, you ask?", "talk", "whoAmI/0", 0.045, 1],
                        ["Well, I'm kinda lost, to be honest...", "embarrassed", "whoAmI/1", 0.045, 1],
                        ["But at the same time, I've never felt so close to myself!", "hype", "whoAmI/2", 0.055, 1.6],
                        ["Err... that doesn't answer your question very well, right?", "embarrassed", "whoAmI/3", 0.05, 0.7],
                        ["Forget about it! Just call me Maigo.", "talk", "whoAmI/4", 0.05, 1.8]
                    ]);

                    maigo.onEndReached = function ()
                    {
                        maigoDialogues.push(file[1]);
                        for (i in [FlxG.sound.music, windowsSound]) FlxTween.tween(i, {volume: 1}, 0.5);
                    }
                });
            }

        case "bf":
            windowBioText.y = 410;
            windowBioText.text = "Week after week, Boyfriend would rap against various friends and foes alike to secure the love of his life, Girlfriend. After inserting the disc holding Sonic's game into his computer, he was claimed by the anomaly, now forced to sing for eternity within it's digital hell.\n\nDEBUT: FRIDAY NIGHT FUNKIN' (2020)\nALIAS: BF, Boyfriend.xml";
            curRows = 6.4;
            curRowsScroll = 1.6;
            windowCamera.maxScrollY = 760;
    }

    if (windowTitle.text.length >= 35) {
        windowTitle.size = 47;
        windowTitle.y = 65;
    }

    if (windowTitle.text.length >= 38) {
        windowTitle.size = 41;
        windowTitle.y = 67;
    }

    if (windowTitle.text.length >= 44) {
        windowTitle.size = 40;
        windowTitle.y = 69;
    }

    switch (file[1]) // POSITIONING
    {
        case "sonic":
            windowImage.setPosition(270, 125);
            windowImage.scale.set(2.1, 2.1);

        case "sonic-midareta":
            windowImage.setPosition(190, 125);
            windowImage.scale.set(2.1, 2.1);

        case "sonic-wurugashikoi":
            windowImage.setPosition(240, 130);
            windowImage.scale.set(2.1, 2.1);

        case "sonic-kyokai":
            windowImage.setPosition(195, 130);
            windowImage.scale.set(1.75, 1.75);

        case "majin":
            windowImage.setPosition(245, 120);
            windowImage.scale.set(2, 2);

        case "majin-fusion":
            windowImage.setPosition(215, 130);
            windowImage.scale.set(2.2, 2.2);

        case "2011X":
            windowImage.setPosition(245, 130);
            windowImage.scale.set(2.1, 2.1);

        case "2011X-rodentrap":
            windowImage.setPosition(30, -100);
            windowImage.scale.set(0.675, 0.675);
            windowImage.antialiasing = ClientPrefs.data.antialiasing;

        case "lordX":
            windowImage.setPosition(200, 130);
            windowImage.scale.set(2.1, 2.1);

        case "lordX-internal":
            windowImage.setPosition(-65, -285);
            windowImage.scale.set(0.535, 0.535);

        case "victims":
            windowImage.setPosition(160, 125);
            windowImage.scale.set(2, 2);

        case "victims-dead":
            windowImage.setPosition(235, 105);
            windowImage.scale.set(2, 2);

        case "maigo":
            windowImage.setPosition(225, 115);
            windowImage.scale.set(2, 2);

        case "bf":
            windowImage.setPosition(205, 115);
            windowImage.scale.set(2.1, 2.1);
    }

    if (!reloadBioVariants) return;
    curBioSelected = 0;
    curBioVariants = [];
    curBioVariants.push([file[0], file[1]]);
    var bioVariants:Array;

    switch (file[1]) // VARIANTS
    {
        case "majin": bioVariants = [["MAJIN/X\nFUSION", "majin-fusion"]];
        case "2011X": bioVariants = [["2011 X\n(RodentRap)", "2011X-rodentrap"]];
        case "lordX": bioVariants = [["Lord X\n(Internal)", "lordX-internal"]];
        case "sonic": bioVariants = [["Sonic\n(Midareta)", "sonic-midareta"], ["Sonic\n(Wurugashikoi)", "sonic-wurugashikoi"], ["Sonic\n(Kyokai)", "sonic-kyokai"]];
        case "victims": bioVariants = [["The Vessels (Dead)", "victims-dead"]];
        default: bioVariants = [];
    }

    for (i in bioVariants) curBioVariants.push(i);

    windowUpButton.alpha = windowDownButton.alpha = curBioVariants.length > 1;
    windowScrollBar.alpha = windowSlider.alpha = 1;
}

function powerOff()
{
    leaving = true;
    windowsSound.stop();
    windowsSound = FlxG.sound.play(Paths.sound("windowsShutdown"));
    FlxTween.tween(windowsSound, {volume: 0}, 0.5);
    overlay.animation.play("monitorZoom", true, true);
    overlay.animation.finishCallback = function (wow)
    {
        overlay.animation.finishCallback = null;
        saveSeenDialogues();
        MusicBeatState.switchState(new CustomState(), Paths.hscript("states/GalleryState"));
    }
}

function openFile(file:Array)
{
    curPhase = 2;
    clearWindow();
    overlappingFile = false;

    imageFolder = "concepts";
    switch (curFolder)
    {
        case "Joke Imagery": imageFolder = "jokeImagery";
        case "Video Cutscenes": imageFolder = "cutscenes";
        case "Promotional Renders": imageFolder = "promoRenders";
        case "Springless Sketches": imageFolder = "concepts/springSketches";
    }

    pastWindowScroll = windowCamera.scroll.y;
    resizeWindow(1.175, false);

    switch (curFolder)
    {
        case "Character Biographies":
            loadCharacterBio(file, true);
        
        default:
            windowTitle.text = "Photo Viewer - " + StringTools.replace(file[0], "\n", " ");

            if (StringTools.endsWith(file[1], ".png") || StringTools.endsWith(file[1], ".xml")) {
                if (StringTools.endsWith(file[1], ".png")) 
                    windowImage.loadGraphic(Paths.image("menus/gallery/galleryImages/" + imageFolder + "/" + StringTools.replace(file[1], ".png", "")));

                if (StringTools.endsWith(file[1], ".xml")) {
                    var name = StringTools.replace(file[1], ".xml", "");
                    windowImage.frames = Paths.getSparrowAtlas("menus/gallery/galleryImages/" + imageFolder + "/" + name);
                    windowImage.animation.addByPrefix("idle", name + " idle", 30, true);
                    windowImage.animation.play("idle");
                }

                windowImage.alpha = 1;
                windowImage.screenCenter();
                windowImage.y += 30;

                switch (file[1]) // I really did not want to fucking do this
                {
                    case "amigo.png": windowImage.scale.set(1.35, 1.35);
                    case "dedKnuxBeta.png", "awHellNaw.png": windowImage.scale.set(1, 1);
                    case "bfModelBeforeAdjustments.png": windowImage.scale.set(1.1, 1.1);
                    case "diabolicalConcept.png", "earlyMidaretaTest.png": windowImage.scale.set(0.75, 0.75);
                    case "firsteverGHrender.png", "firsteverSonicRender.png": windowImage.scale.set(0.95, 0.95);
                    case "firstSonicSpritesEverDone.png", "blenderSonicTest.xml", "whyIsHeThere.png": windowImage.scale.set(1.1, 1.1);
                    case "galleryConcept.png": windowImage.scale.set(0.885, 0.885);
                    case "gameOverConcept.png": windowImage.scale.set(0.7, 0.7);
                    case "ghFogTest.png", "promoConceptRound2.png", "sonicIfSonicExpression.png", "zombieCanon.png": windowImage.scale.set(2.2, 2.2);
                    case "iamgodsceen sketch.png", "kyokaiformConcept.png", "oldGalleryScreen.png": windowImage.scale.set(0.9, 0.9);
                    case "oldIamGod.png": windowImage.scale.set(0.65, 0.65);

                    case "kyokaiDark.xml": 
                        windowImage.scale.set(0.575, 0.575);
                        windowImage.x -= 30;

                    case "bfLegacySketches.png": windowImage.scale.set(0.53, 0.53);
                    case "lxBeforeAndAfter.png", "uneditedErrorImage.png": windowImage.scale.set(2.1, 2.1);
                    case "maigoSketch.png", "oldmodelPose.png": windowImage.scale.set(0.74, 0.74);
                    case "oldMilesDeath.png": windowImage.scale.set(0.4, 0.4);
                    case "oldRewrite.png": windowImage.scale.set(0.32, 0.32);
                    case "peeloutTest.png": windowImage.scale.set(1.15, 1.15);
                    case "scrappedTrinityEncorePoster.png", "maigoAndsonic.png", "stylizedSonic.png": windowImage.scale.set(0.67, 0.67);
                    case "currentSonic.png": windowImage.scale.set(0.25, 0.25);
                    case "oldModelProcess.png", "banner.png": windowImage.scale.set(0.35, 0.35);
                    case "v3beta.png": windowImage.scale.set(1.2, 1.2);
                    case "thrillerGenPoses.png": windowImage.scale.set(0.79, 0.79);
                    case "xandMajin.png": windowImage.scale.set(1.35, 1.35);
                    case "hugwrite.png", "jonkler.png": windowImage.scale.set(0.5, 0.5);
                    case "cursed.png": windowImage.scale.set(2.25, 2.25);
                    case "oldmodelrender.png": windowImage.scale.set(0.36, 0.36);
                    case "tgAlbumCover.png", "trinityAlbumCover.png": windowImage.scale.set(0.4, 0.4);
                    default: windowImage.scale.set(0.815, 0.815);
                }
            } else if (StringTools.endsWith(file[1], ".mp4")) {
                FlxTween.cancelTweensOf(FlxG.sound.music);
                videoPaused = false;
                videoOver = false;
                windowTitle.text = "Media Player - " + StringTools.replace(file[0], "\n", " ");
                window.loadGraphic(Paths.image("menus/gallery/desktop/videoPlayer/videoPlayer"));
                windowVideo.load(Paths.modFolders('images/menus/gallery/galleryImages/' + imageFolder + '/' + file[1]));
                windowVideo.play();
                windowVideo.offset.y = -31;

                windowVideo.bitmap.onFormatSetup.add(function() {
                    windowVideo.setGraphicSize(532 * 1.17, 452 * 1.17);
                    windowVideo.screenCenter();
                });

                var audioOn:Bool = false;

                switch (file[1])
                {
                    case "majincutscene storyboard.mp4", "fullrewritestoryboard.mp4", "fusionCutscene.mp4", 
                    "lordXCutscene.mp4", "majinCutscene.mp4", "xCutscene.mp4", "iamgood.mp4", "its_rewrover.mp4", "snowLeaksTheModLikeAnIdiot.mp4", "tennaNOOO.mp4", "trinityLegacyIntro.mp4":
                        FlxTween.cancelTweensOf(FlxG.sound.music);
                        FlxG.sound.music.volume = 0;
                        audioOn = true;

                    default:
                        FlxTween.cancelTweensOf(FlxG.sound.music);
                        audioOn = false;
                }

                if (!audioOn) FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.5);

                windowVideo.bitmap.onPlaying.add(function() {
                    windowVideo.alpha = 1;
                });

                windowVideo.bitmap.onEndReached.add(function (){
                    windowVideo.bitmap.time = windowVideo.bitmap.length;
                    videoOver = true;
                    windowPauseButton.animation.play("play");
                });

                windowPauseButton.alpha = windowPreviousButton.alpha = windowNextButton.alpha = windowTimeBar.alpha = windowPlayhead.alpha = 1;
            }
    }

    var description:String = "";
    var size:Float = 40;
    switch (file[1])
    {
        case "amigo.png": description = "A comparison of Sonic's old and current models.";

        case "betarewrite.png": 
            description = "One of the first sketches of Sonic's design, a little more similar to their current look.  At the time of this drawing, it was planned that Sonic would progressively get more similar to his classic EXE appearance as the story progresses. His body would be damaged, making him look like the first ever Rewrite Sonic design most people know.";
            size = 20;

        case "bfLegacySketches.png": 
            description = "Boyfriend sketches done by Springless for the Rodentrap part of Trinity. Later rendered by Jasper and animated by Pootis.";
            size = 30;

        case "bfModelBeforeAdjustments.png": description = "Boyfriend's model, before and after some touchups.";
        case "blenderSonicTest.xml": description = "Sonic's head modeled in Blender as an exercise.";

        case "currentSonic.png": 
            description = "Sonic's current design concept art. Springless wanted to lean even closer to the original Sonic.";
            size = 35;

        case "dedKnuxBeta.png":
            description = "Very early design of Ekiduna's dead vessel. His chest got violently exposed after a spindash from Sonic, and he also lost his arm during a confrontation with him as well.";
            size = 30;

        case "diabolicalConcept.png":
            description = "Very early design of what would later become the Midareta and Kaibutsu (which later went on to be redesigned into Kyokai) forms.";
            size = 30;

        case "earlyMidaretaTest.png":
            description = "Very old version of the Midareta form featured in the Game Over for Terrorizer, a scrapped song from Horizon's Edge.";
            size = 30;

        case "firsteverDialogueConcept.png": description = "Concept art of Sonic's dialogue screen seen in Sonic Gameplay.";
        case "firstSonicSpritesEverDone.png": description = "A bunch of old Sonic sprites based off an early version of their lore.";
        case "gameOverConcept.png": description = "Game Over concept art done by Jasper and later animated by Springless.";
        case "gameoverFormTest.png": description = "Early concept of Legacy Trinity's Game Over.";

        case "kaibutsu.png":
            description = "The scrapped Kaibutsu form of Sonic, replaced by the Kyokai form. The name comes from the fact that this form has a more animalistic feel to it, both in it's movements and it's enormous size, something that the Kyokai form has in common.";
            size = 23;

        case "kyokaiDark.xml":
            description = "Unused alternate sprites of the Kyokai form, meant for the lightning flash parts of Trinity (Encore).";
            size = 35;

        case "legacygameoverunedited.png": description = "Original Legacy Trinity's Game Over, with and without editing.";
        case "lxBeforeAndAfter.png": description = "Lord X's model, before and after some touchups.";

        case "newModelProcess.png": 
            description = "This model was originally going to be just a test of exporting models to Godot. It's original name was 'Sonic PH' (placeholder), but Springless found it's roughness so fitting and charming that she decided to make it the definitive model.";
            size = 23;

        case "oldCreepyform.png": description = "First ever drawing of what would become the Midareta form.";
        case "oldGalleryScreen.png": description = "Old gallery concept art done by Jasper.";
        case "oldIamGod.png": description = "Very old I AM GOD screen sketch, based off of Sonic's old lore.";

        case "oldMilesDeath.png": 
            description = "In the old lore, Miles was going to be killed by Sonic, who got 'angry' after losing a game of Hide n' Seek.";
            size = 33;

        case "oldModelProcess.png":
            description = "Springless pictured this model in her head a little while after VS Rewrite released. She quickly got to work on it, with some inspirations from fanart she saw on Twitter.";
            size = 30;

        case "oldRewrite.png":
            description = "Infamous beta Sonic design based off of their old lore. This design had a more normal looking version that got turned into this for lore reasons.";
            size = 30;

        case "puppet_knuckles_concept.png": description = "Very early design of Ekiduna's dead vessel. He is pale due to blood loss.";

        case "puppet_tails_concept.png":
            description = "Very early design of Miles' dead vessel. He was strangled by Sonic and impaled on a tree top, which later caught fire due to a thunderstorm.";
            size = 31;

        case "resolution.mp4", "cgistyle2.mp4": description = "A video made to test video playing functions.";

        case "sa2spritesSketch.png": 
            description = "Sonic & Boyfriend referencing Sonic Adventure 2 poses in Trinity (Encore). Original idea by Jasper, later touched up by Springless.";
            size = 29;

        case "sonicEarlyConcept.png": description = "Very early concept of Sonic's 'faker' form.";
        case "sonicIfSonicExpression.png": description = "Cursed looking Rewrite Sonic with original Sonic's eyebrow expression.";

        case "stylizedSonic.png", "stylizedSonic2.png": description = "A stylized version of Sonic drawn by Springless several times.";
        case "thrillerGenPoses.png": description = "Legacy Thriller Gen poses concept art.";

        case "zombieCanon.png": 
            description = "A more accurate to canon version of the zombie vessel designs done by Springless, unused due to lack of polish.";
            size = 29;
    }

    if (description != "") maigo.backing.alpha = 0.5;
    descriptionText.text = description;
    descriptionText.size = size;

    if (windowTitle.text.length >= 34) {
        windowTitle.size = 47;
        windowTitle.y = 65;
    }

    if (windowTitle.text.length >= 39) {
        windowTitle.size = 42;
        windowTitle.y = 67;
    }
}

function clearWindow()
{
    clearCurAssetsArray();
    if (windowVideo.alpha == 1) {
        if (windowVideo.bitmap.isPlaying) windowVideo.stop();
        videoPaused = false;
        windowPauseButton.animation.play("pause");
        FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.5);
    }

    windowSlider.alpha = windowScrollBar.alpha = windowImage.alpha = 
    windowVideo.alpha = windowPauseButton.alpha = windowPreviousButton.alpha =
    windowNextButton.alpha = windowTimeBar.alpha = windowPlayhead.alpha = 
    windowUpButton.alpha = windowDownButton.alpha = windowBioText.alpha = 0.001;
    windowImage.antialiasing = false;
    windowImage.camera = FlxG.camera;
    sliderMult = 0;
    curBioVariants = [];
}

function openWindow(app:Array)
{
    if (app[0] == "thisPC" || app[0] == "recycleBin") return;

    if (app[0] == "powerOff") {
        powerOff();
        return;
    }

    resizeWindow(1, curApp == app[0] ? false : true);
    curApp = app[0];
    curFolder = StringTools.replace(app[1], "\n", " ");
    curRows = 1;
    curRowsScroll = 0;
    overlappingApp = overlappingFile = false;
    window.alpha = windowTitle.alpha = 1;
    windowTitle.text = curFolder;
    customCursor.animation.play("default", true);

    videoArray = [];

    window.loadGraphic(Paths.image("menus/gallery/desktop/window"));

    var curY:Float = -20;
    var camScrollY:Float = 460;
    var mult:Float = 0;
    var videoCount:Int = 0;

    for (i in 0...app[5].length) {
        var icon = new FlxSprite(-15 + mult * 82, curY).loadGraphic(Paths.image("menus/gallery/desktop/icons/" + app[5][i][1]));
        icon.scale.set(2.4, 2.4);
        icon.updateHitbox();

        var text = new FlxText(icon.x - 352, icon.y + 93, FlxG.width, app[5][i][0]);
        text.setFormat(Paths.font("windows-xp-tahoma.ttf"), 21, 0xFFFFFFFF, "center", FlxTextBorderStyle.SHADOW, 0xFF272B4F, false);
        text.borderSize = 1.5;

        var hitbox = new FlxSprite(icon.x + 30, icon.y + 22).makeGraphic(58, 68, 0xFFFF0000);
        hitbox.alpha = 0.001;

        for (i in [icon, text]) {
            i.camera = windowCamera;
            game.add(i);
        }

        filesGroup.add(hitbox);

        curAssetsArray.push([icon, text, hitbox, app[5][i][2], app[5][i][1] == "video" ? Std.string(videoCount) : Std.string(i)]);
        if (app[5][i][1] == "video") {
            videoArray.push([text.text, app[5][i][2], Std.string(videoCount)]);
            videoCount += 1;
        }

        mult += 1;
        if (mult > 5) {
            if (curAssetsArray.length >= 24) {
                camScrollY += 115;
                curRowsScroll += 1;
            }
            curY += 115;
            mult = 0;
            curRows += 1;
        }
    }

    windowCamera.minScrollY = 0;
    windowCamera.maxScrollY = camScrollY;
    sliderMult = curAssetsArray.length;
    if (sliderMult >= 24) {
        windowScrollBar.alpha = windowSlider.alpha = 1;
    } else {
        windowCamera.scroll.y = 0;
    }
}

function saveSeenDialogues()
{
    for (i in maigoDialogues) {
        if (FlxG.save.data.seenMaigoDialogues.contains(i)) continue;
        FlxG.save.data.seenMaigoDialogues.push(i);
    }

    FlxG.save.flush();
}