import backend.Controls;
import backend.Discord;
import flixel.sound.FlxSound;
import flixel.addons.transition.FlxTransitionableState;
import flixel.text.FlxText;
import objects.MaigoSpeaker;
import Main;

var underlay:FlxSprite;
var main:FlxSprite;

var painting:FlxSprite;
var paintingHitbox:FlxSprite;

var art:FlxSprite;
var artHitbox:FlxSprite;

var music:FlxSprite;
var musicHitbox:FlxSprite;

var maigo:FlxSprite;
var maigoSpeaker:MaigoSpeaker;
var maigoHitbox:FlxSprite;
var maigoIntroduction:Bool = false;
var maigoIntroAnim:FlxSprite;
var maigoEmotes:FlxSprite;
var prevMaigoConversation:Int = -1;

var back:FlxSprite;
var customCursor:FlxSprite;

var allowInput:Bool = true;
var allowMouse:Bool = true;
var galleryPhase:Int = 0;
var overlaps:Bool = false;
var debug:Bool = false;

var maigoDialogues:Array<String> = [];

function onCreate()
{
    Paths.clearStoredMemory();

    FlxTransitionableState.skipNextTransIn = true;
    FlxTransitionableState.skipNextTransOut = true;

    FlxG.mouse.useSystemCursor = false;
    FlxG.mouse.visible = false;

    DiscordClient.changePresence("Gallery", null);

    if (!CustomState.dataSelect) {
        FlxG.camera.alpha = 0;
        new FlxTimer().start(0.001, function(tmr) {
            FlxG.camera.alpha = 1;
            FlxG.camera.flash(0xFF000000, 0.6);
        });
    }

    underlay = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFF393C10);
    underlay.scale.set(1000, 1000);
    underlay.screenCenter();
    game.add(underlay);

    maigoDialogues = FlxG.save.data.seenMaigoDialogues;

    main = new FlxSprite(0, 0);
    main.frames = Paths.getSparrowAtlas("menus/gallery/room");
    main.animation.addByPrefix("main", "room", 15, true);
    main.animation.addByPrefix("monitorZoom", "monitorZoom", 15, false);
    main.animation.addByPrefix("discmanZoom", "discmanZoom", 15, false);
    main.animation.addByPrefix("paintingZoom", "paintingZoom", 15, false);
    main.animation.play("main", true);
    main.scale.set(3.5, 3.5);
    main.screenCenter();
    game.add(main);

    painting = new FlxSprite(607.5, 261.5).loadGraphic(Paths.image("menus/gallery/painting"));
    painting.scale.set(3.5, 3.5);
    game.add(painting);

    paintingHitbox = new FlxSprite(550, 225).makeGraphic(160, 115, 0xFFFFFFFF);
    paintingHitbox.alpha = 0.001;
    paintingHitbox.angle = -5;
    game.add(paintingHitbox);

    art = new FlxSprite(448.5, 387.9);
    art.frames = Paths.getSparrowAtlas("menus/gallery/monitor");
    art.animation.addByPrefix("main", "monitor", 15, false);
    art.animation.addByPrefix("static", "staticMonitor", 15, true);
    art.animation.play("main");
    art.scale.set(3.5, 3.5);
    game.add(art);

    artHitbox = new FlxSprite(418, 353).makeGraphic(88, 98, 0xFFFFFFFF);
    artHitbox.alpha = 0;
    game.add(artHitbox);

    music = new FlxSprite(561.5, 435.9).loadGraphic(Paths.image("menus/gallery/discman"));
    music.scale.set(3.5, 3.5);
    game.add(music);

    musicHitbox = new FlxSprite(527, 419).makeGraphic(105, 45, 0xFFFFFFFF);
    musicHitbox.alpha = 0;
    game.add(musicHitbox);

    maigo = new FlxSprite(310, 275);
    maigo.frames = Paths.getSparrowAtlas("menus/gallery/maigo/gallery");
    maigo.animation.addByPrefix("idleA", "idleA", 15, true);
    maigo.animation.addByPrefix("idleB", "idleB", 15, true);
    maigo.animation.addByPrefix("idleC", "idleC", 15, true);
    var maigoIdles = ["idleA", "idleB", "idleC"];
    maigo.animation.play(maigoIdles[FlxG.random.int(0, maigoIdles.length - 1)]);
    maigo.scale.set(3, 3);
    game.add(maigo);

    maigoHitbox = new FlxSprite(10, 275).makeGraphic(10, 10, 0xFFFFFFFF);
    maigoHitbox.alpha = 0;
    game.add(maigoHitbox);

    switch (maigo.animation.curAnim.name)
    {
        case "idleA":
            maigoHitbox.setPosition(126, 125);
            maigoHitbox.scale.set(17, 50);

        case "idleB":
            maigoHitbox.setPosition(145, 120);
            maigoHitbox.scale.set(15, 51);

        case "idleC":
            maigoHitbox.setPosition(106, 125);
            maigoHitbox.scale.set(21, 50);
    }

    maigoHitbox.updateHitbox();

    Paths.clearUnusedMemory();
    CustomState.dataSelect = false;

    maigoEmotes = new FlxSprite();
    maigoEmotes.frames = Paths.getSparrowAtlas("menus/gallery/maigo/galleryEmotes");
    maigoEmotes.animation.addByPrefix("talk", "talk", 15, true);
    maigoEmotes.animation.addByPrefix("hype", "hype", 15, true);
    maigoEmotes.animation.addByPrefix("sad", "sad", 15, true);
    maigoEmotes.animation.addByPrefix("shy", "shy", 15, true);
    maigoEmotes.animation.addByPrefix("book", "book", 15, false);
    maigoEmotes.animation.addByPrefix("hand", "hand", 15, true);
    maigoEmotes.scale.set(3.3, 3.3);
    maigoEmotes.screenCenter();
    maigoEmotes.x -= 30;
    maigoEmotes.alpha = 0.001;
    game.add(maigoEmotes);

    maigoIntroAnim = new FlxSprite();
    maigoIntroAnim.frames = Paths.getSparrowAtlas("menus/gallery/maigo/intro");
    maigoIntroAnim.animation.addByPrefix("anim", "anim", 15, false);
    maigoIntroAnim.scale.set(3.3, 3.3);
    maigoIntroAnim.screenCenter();
    maigoIntroAnim.alpha = 0.001;
    game.add(maigoIntroAnim);

    back = new FlxSprite(10, 635).loadGraphic(Paths.image("menus/options/back"));
    back.scale.set(3, 3);
    back.updateHitbox();
    back.alpha = 0.001;
    game.add(back);

    maigoSpeaker = new MaigoSpeaker();
    game.add(maigoSpeaker);

    customCursor = new FlxSprite(-100, -100); // this really sucks
    customCursor.frames = Paths.getSparrowAtlas("cursor");
    customCursor.animation.addByPrefix("default", "default", 24, false);
    customCursor.animation.addByPrefix("wait", "wait", 24, false);
    customCursor.animation.addByPrefix("hover", "hover", 24, false);
    customCursor.animation.play("default");
    customCursor.scale.set(1.5, 1.5);
    game.add(customCursor);

    Paths.sound("maigo/intro");

    if (!FlxG.save.data.seenMaigoIntroduction || debug) {
        allowInput = false;
        customCursor.animation.play("default", true);
        maigo.alpha = 0.001;
        maigoIntroduction = true;

        new FlxTimer().start(0.5, function(tmr) {
            startMaigoIntroduction();
        });
    } else {
        back.alpha = 1;
        playMusic();
    }
}

function playMusic()
{
    if (FlxG.sound.music == null) FlxG.sound.playMusic(Paths.music("meet-maigo"), 1);
    if (FlxG.sound.music.paused) FlxG.sound.music.resume();
    FlxG.sound.music.play();
    FlxG.sound.music.volume = 1;
}

function startMaigoIntroduction()
{
    allowInput = false;
    customCursor.animation.play("default", true);

    maigo.alpha = 0.001;
    maigoIntroduction = true;
    maigoIntroAnim.alpha = 1;
    maigoIntroAnim.animation.play("anim", true);
    FlxG.sound.play(Paths.sound("maigo/intro"));
    startMaigoDialogue();
    maigoSpeaker.swapSpeaker(false);

    new FlxTimer().start(13, function(tmr) {
        allowInput = true;
        maigo.alpha = 1;
        maigoIntroduction = false;
        maigoIntroAnim.alpha = 0.001;
        maigoSpeaker.text.resetText('');
        maigoSpeaker.backing.alpha = 0.001;
        maigoSpeaker.text.fieldWidth = 580;
        maigoSpeaker.swapSpeaker(true);
        playMusic();
        back.alpha = 1;
        FlxG.save.data.seenMaigoIntroduction = true;
        FlxG.save.flush();
    });
}

function startMaigoDialogue()
{
    new FlxTimer().start(0.85, function(tmr) {
        maigoSpeaker.text.x = 0;
        maigoSpeaker.text.resetText("Salutations, my friend!");
        maigoSpeaker.text.fieldWidth = FlxG.width;
        maigoSpeaker.backing.alpha = 0.5;
        maigoSpeaker.text.start(0.00000001, true, false, null, null);
    });

    new FlxTimer().start(2.67, function(tmr) {
        maigoSpeaker.text.resetText("Welcome to my place of abode!");
        maigoSpeaker.text.start(0.00000001, true, false, null, null);
    });

    new FlxTimer().start(4.94, function(tmr) {
        maigoSpeaker.text.resetText("I didn't have time to set the cubes and triangles in their designated places,");
        maigoSpeaker.text.start(0.00000001, true, false, null, null);
    });

    new FlxTimer().start(8.93, function(tmr) {
        maigoSpeaker.text.resetText("Excuse me for that there, all over the place,");
        maigoSpeaker.text.start(0.00000001, true, false, null, null);
    });

    new FlxTimer().start(10.75, function(tmr) {
        maigoSpeaker.text.resetText("But please! Make yourself at home.");
        maigoSpeaker.text.start(0.00000001, true, false, null, null);
    });
}

function onUpdate(e)
{
    customCursor.x = FlxG.mouse.x;
    customCursor.y = FlxG.mouse.y;

    var overlaps = (FlxG.mouse.overlaps(artHitbox) && galleryPhase == 0 || 
    FlxG.mouse.overlaps(musicHitbox) && galleryPhase == 0 ||
    FlxG.mouse.overlaps(paintingHitbox) && galleryPhase == 0 ||
    FlxG.mouse.overlaps(maigoHitbox) && galleryPhase == 0 ||
    FlxG.mouse.overlaps(back) && back.alpha == 1);

    if (!maigoSpeaker.currentlySpeaking) {
        if (allowInput && overlaps) {
            customCursor.animation.play("hover", true);
        } else if (allowInput && !overlaps) {
            customCursor.animation.play("default", true);
        } else if (!allowInput && !maigoIntroduction) {
            customCursor.animation.play("wait", true);
        }
    }

    if (maigoSpeaker.currentlySpeaking) customCursor.animation.play("default", true);

    if (allowInput && !maigoSpeaker.currentlySpeaking) {
        switch (galleryPhase) {
            case 0:
                if (FlxG.mouse.justPressed && allowMouse) {
                    if (FlxG.mouse.overlaps(paintingHitbox)) {
                        allowInput = false;
                        for (i in [painting, music, art, maigo, back]) i.alpha = 0.001;
                        main.animation.play("paintingZoom", true);
                        main.animation.finishCallback = function (wow)
                        {
                            galleryPhase = 1;
                            main.animation.finishCallback = null;
                            allowInput = true;
                            customCursor.animation.play("default", true);

                            var seenDialogue:Bool = false;

                            for (i in maigoDialogues) {
                                if (i == "maigoArtwork") {
                                    seenDialogue = true;
                                    break;
                                }
                            }
                            if (!seenDialogue) {
                                new FlxTimer().start(0.7, function(tmr) {
                                    FlxTween.tween(FlxG.sound.music, {volume: 0.3}, 0.2);
                                    maigoSpeaker.onEndReached = function ()
                                    {  
                                        back.alpha = 1;
                                        FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.2);
                                        maigoDialogues.push("maigoArtwork");
                                    }
                                    maigoSpeaker.startDialogue([
                                        ["Ah... what a delightful piece of art!", "eyesClosed", "artwork/0", 0.05, 1.6, 39],
                                        ["I don't recall where I got this from, but it almost feels like something sacred...", "talk", "artwork/1", 0.05, 1.6, 29]
                                    ]);
                                });
                            } else {
                                back.alpha = 1;
                            }
                        }
                    } else if (FlxG.mouse.overlaps(musicHitbox)) {
                        allowInput = false;
                        for (i in [painting, music, art, maigo, back]) i.alpha = 0.001;
                        main.animation.play("discmanZoom", true);
                        main.animation.finishCallback = function (wow)
                        {
                            main.animation.finishCallback = null;
                            Paths.clearUnusedMemory();
                            saveSeenDialogues();
                            MusicBeatState.switchState(new CustomState(), Paths.hscript("states/gallery/MusicPlayerState"));
                        }
                    } else if (FlxG.mouse.overlaps(artHitbox)) {
                        allowInput = false;
                        for (i in [painting, music, art, maigo, back]) i.alpha = 0.001;
                        underlay.color = 0xFF0F070F;
                        main.animation.play("monitorZoom", true);
                        main.animation.finishCallback = function (wow)
                        {
                            main.animation.finishCallback = null;
                            Paths.clearUnusedMemory();
                            saveSeenDialogues();
                            MusicBeatState.switchState(new CustomState(), Paths.hscript("states/gallery/ComputerState"));
                        }
                    } else if (FlxG.mouse.overlaps(maigoHitbox)) {
                        maigo.alpha = 0.001;
                        back.alpha = 0.001;
                        var maigoConversation = FlxG.random.int(0, 4, [prevMaigoConversation]);
                        prevMaigoConversation = maigoConversation;
                        maigoSpeaker.swapSpeaker(false);
                        maigoSpeaker.emoteOutput = maigoEmotes;
                        maigoSpeaker.onEndReached = function ()
                        {
                            back.alpha = 1;
                            maigoEmotes.alpha = 0.001;
                            maigo.alpha = 1;
                            maigoSpeaker.emoteOutput = maigoSpeaker.icon;
                            maigoSpeaker.swapSpeaker(true);
                            FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.2);
                        }
                        new FlxTimer().start(0.1, function(tmr) {
                            maigoEmotes.alpha = 1;
                            FlxTween.tween(FlxG.sound.music, {volume: 0.3}, 0.2);
                            switch (maigoConversation)
                            {
                                case 0:
                                    maigoSpeaker.startDialogue([
                                        ["Needing a hand, fella?", "talk", "needingAHand/0", 0.05, 1],
                                        ["I can lend you mine if you want!", "hand", "needingAHand/1", 0.05, 1],
                                        ["Just don't lose it, okay?", "shy", "needingAHand/2", 0.06, 1],
                                        ["I can't spend another week trying to find it, like that time Mr. Sonic pranked me...", "sad", "needingAHand/3", 0.045, 0.8, 30]
                                    ]);

                                case 1:
                                    maigoSpeaker.startDialogue([
                                        ["Feel free to look around!", "hype", "lookAround/0", 0.05, 0.7],
                                        ["I just like standing here.", "talk", "lookAround/1", 0.05, 1],
                                    ]);

                                case 2:
                                    maigoSpeaker.startDialogue([
                                        ["Did you know a triangle has the same amount of sides as a cube?", "talk", "geometry/0", 0.06, 1.5, 35],
                                        ["Well, me neither...", "shy", "geometry/1", 0.05, 1],
                                        ["Thank God I always carry my geometry book around!", "book", "geometry/2", 0.05, 0.7]
                                    ]);

                                case 3:
                                    maigoSpeaker.startDialogue([
                                        ["Hello!", "talk", "hello/" + FlxG.random.int(0, 2), 0.05, 0.8]
                                    ]);

                                case 4:
                                    maigoSpeaker.startDialogue([
                                        ["You're also friends with Mr. Sonic, aren't you?", "hype", "mrSonic", 0.045, 1]
                                    ]);
                            }
                        });
                    }
                }
        }

        if (controls.BACK && !maigoSpeaker.currentlySpeaking || FlxG.mouse.justPressed && FlxG.mouse.overlaps(back)) leaveGallery();
    }
}

function leaveGallery()
{
    switch (galleryPhase)
    {
        case 0:
            allowInput = false;
            allowMouse = false;
            galleryPhase = -1;
            for (i in [main, painting, music, art, customCursor, maigo, back]) FlxTween.color(i, 0.4, 0xFFFFFFFF, 0xFF0000FF);
            FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.5);
            FlxG.camera.fade(0xFF000000, 0.7, false, null, true);
            new FlxTimer().start(0.75, function(tmr) {
                FlxG.sound.music.stop();
                FlxG.sound.music = null;
                saveSeenDialogues();
                MusicBeatState.switchState(new CustomState(), Paths.hscript("states/MainMenuState"));
            });

        case 1:
            allowInput = false;
            back.alpha = 0.001;
            main.animation.play("paintingZoom", true, true);
            main.animation.finishCallback = function (wow)
            {
                back.alpha = 1;
                galleryPhase = 0;
                main.animation.play("main", true);
                main.animation.finishCallback = null;
                allowInput = true;
                var maigoIdles = ["idleA", "idleB", "idleC"];
                maigo.animation.play(maigoIdles[FlxG.random.int(0, maigoIdles.length - 1)]);
                for (i in [painting, music, art, maigo]) i.alpha = 1;
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