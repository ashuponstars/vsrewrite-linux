-- coding a game over screen in lua...
-- if ths sucks i'll get pootis to do this in hscript LOL but should be ok!!!

local eyeShake = 20
local eyeShakeSpeed = 0.1

local defeat = false

local timer = 21.7
local startcounting = false
local hasRetried = false
local countdowntime = 10
local nextnumber = 9

local curCharacter = "SonicTGE"
local maxLines = 0 -- WILL UPDATE onGameOver()

local noMoreDeath = false

-- this sucks
local lordXSubtitles = {
    [0] = function ()
        doSubtitles("I MAY BE THE FIRST...")
        runTimer('lordX0', 2.75)
    end,

    [1] = function ()
        doSubtitles("WELCOME BACK, OLD FRIEND.")
    end,

    [2] = function ()
        doSubtitles("EACH DEATH FEEDS THE CYCLE.")
    end,

    [3] = function ()
        doSubtitles("TELL ME... ARE YOU LISTENING?")
    end,

    [4] = function ()
        doSubtitles("YOUR EXECUTION IS AT HAND.")
    end,

    [5] = function ()
        doSubtitles("YOU'RE GOING TO REMEMBER THIS.")
    end,

    [6] = function ()
        doSubtitles("WHEN YOU DIE, WE'LL MEET AGAIN.")
    end,

    [7] = function ()
        doSubtitles("FINALLY... I MISSED THIS QUIET.")
    end,

    [8] = function ()
        doSubtitles("GET LOST.")
    end,

    [9] = function ()
        doSubtitles("SUCH TENDER FLESH... WHAT A WASTE.")
    end,

    [10] = function ()
        doSubtitles("YOU'VE MET YOUR LORD NOW.")
    end
}

local XSubtitles = {
    [0] = function ()
        doSubtitles("TIME MAY BRING CHANGES AS IT PASSES,")
        runTimer("2011X0", 3.0)
    end,

    [1] = function ()
        doSubtitles("FOUND YOU!")
    end,

    [2] = function ()
        doSubtitles("THIS CLICHE NEVER DIES...")
    end,

    [3] = function ()
        doSubtitles("YOU CAN'T RUN...")
        runTimer("2011X3", 1.5)
    end,

    [4] = function ()
        doSubtitles("THIS REALLY WAS...")
        runTimer("2011X4", 2.1)
        runTimer("2011X4-2", 3.9)
    end,

    [5] = function ()
        doSubtitles("SO LITTLE TIME...")
        runTimer("2011X5", 3.0)
    end,

    [6] = function ()
        doSubtitles("READY FOR ROUND 2?")
    end,

    [7] = function ()
        doSubtitles("I'M GONNA GETCHA~!")
    end,

    [8] = function ()
        doSubtitles("I AM GOD!")
    end,

    [9] = function ()
        doSubtitles("SONIC LOVES TO SEE YOU RUN...")
        runTimer("2011X9", 2.6)
    end,

    [10] = function ()
        doSubtitles("I'M SONIC.EXE AND I AM EVIL!")
    end
}

local majinSubtitles = {
    [0] = function ()
        doSubtitles("IT SEEMS YOUR FUN WAS SHORT-LIVED!")
    end,

    [1] = function ()
        doSubtitles("YOUR ENDEAVORS WERE FUTILE, MY FRIEND.")
    end,

    [2] = function ()
        doSubtitles("YOUR CAREER IS THE\nFALL OF AN ENTERPRISE!")
    end,

    [3] = function ()
        doSubtitles("LET'S GO FOR AN ENCORE!")
    end,

    [4] = function ()
        doSubtitles("CALL ME THE CHAOTIC EVIL!")
    end,

    [5] = function ()
        doSubtitles("INFINITE FUN, INFINITE CHANCES...")
    end,

    [6] = function ()
        doSubtitles("LET YOUR SPIRIT LEAVE YOUR BODY...")
    end,

    [7] = function ()
        doSubtitles("THE FUN WAS JUST GETTING STARTED!")
        runTimer("majin7", 2.83)
    end,

    [8] = function ()
        doSubtitles("YOUR LIFE ISN'T SO ENDLESS...")
    end,

    [9] = function ()
        doSubtitles("HO HO HO HO HO HO HO HO!")
    end
}

local sonicTGESubtitles = {
    [0] = function ()
        doSubtitles("TOO BAD.")
    end,

    [1] = function ()
        doSubtitles("BETTER LUCK NEXT TIME!")
    end,

    [2] = function ()
        doSubtitles("COME ON! DON'T GIVE UP JUST YET.")
    end,

    [3] = function ()
        doSubtitles("WHY NOT TRY AGAIN?")
    end,

    [4] = function ()
        doSubtitles("DON'T FEEL BAD! I KNOW YOU'RE TRYING.")
    end,

    [5] = function ()
        doSubtitles("OOPS!")
    end,

    [6] = function ()
        doSubtitles("どんどん進んで！")
    end
}

local sonicTGEMidaretaSubtitles = {
    [0] = function ()
        doSubtitles("LET'S PLAY AGAIN.")
    end,

    [1] = function ()
        doSubtitles("YOUR CHANCES AREN'T OVER.")
    end,

    [2] = function ()
        doSubtitles("WHY DON'T WE BET YOUR\nFINGERTIPS IN THE NEXT TRY?")
    end,

    [3] = function ()
        doSubtitles("I'M SORRY.")
    end,

    [4] = function ()
        doSubtitles("WE'RE NOT DONE JUST YET.")
    end
}

local sonicTrinitySubtitles = {
    [0] = function ()
        doSubtitles("IT LOOKS LIKE I'M THE BEST,\nAND YOU'RE THE WORST!")
    end,

    [1] = function ()
        doSubtitles("DON'T FEEL BAD!\nI KNOW YOU'RE TRYING...")
        runTimer("sonicTrinity1", 3.3)
    end,

    [2] = function ()
        doSubtitles("地獄じゃ未来、眩しくねぇな")
    end,

    [3] = function ()
        doSubtitles("IT'S A SHAME YOU'LL HAVE TO\nSTART FROM THE BEGINNING AGAIN...")
    end,

    [4] = function ()
        doSubtitles("IT WOULDN'T BE SO FUN\nIF IT WAS FIRST TRY!")
    end,

    [5] = function ()
        doSubtitles("SO MANY GAMES TO PLAY...")
        runTimer("sonicTrinity5", 2.41)
    end,

    [6] = function ()
        doSubtitles("YOU KNOW MY NATURE,")
        runTimer("sonicTrinity6", 1.37)
    end,

    [7] = function ()
        doSubtitles("I AM GOD!")
        runTimer("sonicTrinity7", 1.83)
    end,
}

local fusionSubtitles = {
    [0] = function ()
        doSubtitles("LET'S GO FOR AN ENCORE!")
        runTimer("fusion0", 0.9)
        runTimer("fusion0-1", 1.39)
    end,

    [1] = function ()
        doSubtitles("INFINITE FUN, INFINITE CHANCES...")
        runTimer("fusion1", 1.61)
    end,

    [2] = function ()
        doSubtitles("CALL ME THE CHAOTIC EVIL!")
        runTimer("fusion2", 0.8)
    end,

    [3] = function ()
        doSubtitles("FOUND YOU!")
        runTimer("fusion3", 1.84)
    end
}

-- STEALING THE COUNTDOWN CODE FROM MY PENDRIVE MOD TEEHEE

function onCreate()

    if songName == 'Trinity Legacy' or songName == 'Thriller Gen Legacy' then
        close(false);
    end

    makeLuaSprite("eyesShakeVar", 0, 0)
    setProperty("eyesShakeVar.x", 0)

    makeLuaSprite("eyesShakeSpeedVar", 0.2, 0)
    setProperty("eyesShakeSpeedVar.x", 0.2)

    precacheImage("gameOver/internalXGameOver") -- just in case it needs to swap
    precacheImage("characters/BFRodentRap-death") -- hi i like huggy wuggy

    updateGameOverChar(dadName)
end

function updateGameOverChar(name)
    curCharacter = name

    -- corrections
    if curCharacter == "Monitor" then curCharacter = "Majin" end
    if curCharacter == "LordXB" then curCharacter = "LordX" end
    if curCharacter == "sonicFirstPerson" or curCharacter == "sonicTGE" or curCharacter == "Sonic" or curCharacter == "sonicFall" then curCharacter = "SonicTGE" end
    if curCharacter == "sonicMidareta" then curCharacter = "SonicTGEMidareta" end
    if curCharacter == "sonicWurugashikai" or curCharacter == "sonicWurugashikaiDark" then curCharacter = "SonicTrinity" end
end

function onEvent(e, v1, v2)
    if e == "Change Character" and (v1 == "Dad" or v1 == "dad") then
        updateGameOverChar(v2)
    end
end

function onGameOver()
    if not noMoreDeath then
        if curCharacter == "sonicKyokai" then 
            addLuaScript('scripts/gameOvers/kyokai', false)
            close(false); 
        else -- making this an else cuz it's not supposed to activate the rest of this if the kyokai game over is active
            runHaxeCode([[
                FlxG.scaleMode = PlayState.getRatioScaleMode();
                FlxG.resizeGame(820, 720);
                FlxG.resizeWindow(820, 720);
            ]]);

            setPropertyFromClass('openfl.Lib', 'application.window.borderless', false)

            setProperty("camOther.alpha", 1)
            setProperty("camOther.visible", true)
            doTweenX('camOtherX', 'camOther', -230, 0.01, 'quadOut') -- just to (hopefully) put the camera back as it should be on death

            -- max lines
            if curCharacter == "LordX" or curCharacter == "X" then maxLines = 10 end

            if curCharacter == "XRodentRap" then
                maxLines = 16
                setPropertyFromClass("substates.GameOverSubstate", "characterName", "BFRodentRap-dead")
                setPropertyFromClass("substates.GameOverSubstate", "deathSoundName", "fnf_loss_sfx-nomic")
                setPropertyFromClass("substates.GameOverSubstate", "loopSoundName", "gameOver-fnf")
                setPropertyFromClass("substates.GameOverSubstate", "endSoundName", "gameOverEnd-fnf")
                addLuaScript('scripts/gameOvers/rodentrap', false)
                close(false); -- stops this shit from loading everything else
            end

            if curCharacter == "Majin" then maxLines = 9 end

            if curCharacter == "LordXInternal" then
                addLuaScript('scripts/gameOvers/internalX', false)
                close(false); -- stops this shit from loading everything else
            end

            if curCharacter == "SonicTGE" then maxLines = 6 end
            if curCharacter == "SonicTGEMidareta" then maxLines = 4 end
            if curCharacter == "SonicTrinity" then maxLines = 7 end
            if curCharacter == "Fusion" then maxLines = 3 end
        end
    end
end

function onGameOverStart()
    if not noMoreDeath then
        setPropertyFromClass('openfl.Lib', 'application.window.title', "")
        setPropertyFromClass('openfl.Lib', 'application.window.opacity', 1)

        runHaxeCode([[
            FlxG.game.setFilters([]);

            var stage = Lib.current.stage;
            var resolutionX = 0;
            var resolutionY = 0;

            if (stage.window != null)
            {
                var display = stage.window.display;

                if (display != null)
                {
                    resolutionX = Math.ceil(display.currentMode.width * stage.window.scale);
                    resolutionY = Math.ceil(display.currentMode.height * stage.window.scale);
                }
            }

            if(resolutionX <= 0){
                resolutionX = stage.stageWidth;
                resolutionY = stage.stageHeight;
            }

        Lib.application.window.x = (resolutionX - Lib.application.window.width)/2;
        Lib.application.window.y = (resolutionY - Lib.application.window.height)/2;
        ]]); -- centers the game when ded, doing this on START just to make sure it actually centers cuz it can be weird sometimes

        setProperty("isEnding", true) -- basically if true, locks the input until the player is allowed to reset (it does more than that tbf, but in this case it's what i'll be doing to lock the input)

        runTimer('tryAgain', 1.5)
        runTimer('wompwomp', 1.8)
        runTimer('deadTrack', 2.5)

        makeAnimatedLuaSprite("bgGameOver", "gameOver/bgGameOver", 230, 0)
        addAnimationByPrefix('bgGameOver', 'ded', '0_', 30, false)
        playAnim("bgGameOver", "ded", true, false, 0)
        setProperty("bgGameOver.antialiasing", false)
        scaleObject("bgGameOver", 3.25, 3.25)
        setObjectCamera("bgGameOver", 'other')
        addLuaSprite("bgGameOver", false)

        makeAnimatedLuaSprite("bfGameOver", "gameOver/boyfriendGameOver", 230, 0)
        addAnimationByPrefix('bfGameOver', 'loss', '0_', 30, false)
        addAnimationByPrefix('bfGameOver', 'confirm', 'confirm', 30, false)
        addAnimationByPrefix('bfGameOver', 'death', 'death', 30, false)
        addAnimationByPrefix('bfGameOver', 'deathFrane', 'freezeDeath', 1, false)
        playAnim("bfGameOver", "loss", true, false, 0)
        setProperty("bfGameOver.antialiasing", false)
        scaleObject("bfGameOver", 3.25, 3.25)
        setObjectCamera("bfGameOver", 'other')
        addLuaSprite("bfGameOver", false)

        makeLuaSprite("try", "gameOver/try", -230*3.25, -100)
        setProperty("try.antialiasing", false)
        scaleObject("try", 3.25, 3.25)
        setObjectCamera("try", 'other')
        addLuaSprite("try", false)

        makeLuaSprite("again", "gameOver/again", 230*3.25, -100)
        setProperty("again.antialiasing", false)
        scaleObject("again", 3.25, 3.25)
        setObjectCamera("again", 'other')
        addLuaSprite("again", false)

        makeLuaText("countdown", "10", 150, 565, 220)
        setTextSize("countdown", 6*8)
        setScrollFactor('countdown', 0,0)
        setObjectCamera('countdown', 'other')
        setTextColor("countdown", "FF0000")
        addLuaText("countdown")
        setTextAlignment("countdown", 'center')
        setTextFont("countdown", "sonicCD.ttf")
        setTextBorder("countdown", 0)
        setProperty('countdown.alpha',0)
        setProperty('countdown.antialiasing', false)

        makeLuaSprite("eyes", "gameOver/eyes", 230, 0)
        setProperty("eyes.antialiasing", false)
        scaleObject("eyes", 3.25, 3.25)
        setObjectCamera("eyes", 'other')
        addLuaSprite("eyes", false)
        doTweenX("eyesShake1", "eyes", 230-eyeShake, eyeShakeSpeed, "linear")
        setProperty("eyes.alpha", 0.001)

        makeAnimatedLuaSprite("jumpscare", "gameOver/jumpscareGameOver", 230, 0)
        addAnimationByPrefix('jumpscare', 'jumpscare', 'jumpscare', 30, false)
        addAnimationByPrefix('jumpscare', 'jumpscare2', 'jumpscare', 30, false)
        playAnim("jumpscare", "jumpscare2", true, false, 0)
        setProperty("jumpscare.antialiasing", false)
        scaleObject("jumpscare", 3.25, 3.25)
        setObjectCamera("jumpscare", 'other')
        addLuaSprite("jumpscare", false)
        setProperty("jumpscare.alpha", 0.001)

        makeLuaSprite("defeat", "gameOver/defeat", -230*3.25, 0)
        setProperty("defeat.antialiasing", false)
        scaleObject("defeat", 3.25, 3.25)
        setObjectCamera("defeat", 'other')
        addLuaSprite("defeat", false)

        makeLuaText("subtitles", "", 1280, 0, 330)
        setTextSize("subtitles", 6*7)
        setScrollFactor('subtitles', 0,0)
        setObjectCamera('subtitles', 'other')
        setTextColor("subtitles", "FFFFFF")
        addLuaText("subtitles")
        setTextFont("subtitles", "sonic2HUD.ttf")
        setTextBorder("subtitles", 1.7, "000000", "outline")
        setProperty('subtitles.alpha', 0.001)
        setProperty('subtitles.antialiasing', false)
        setTextAlignment("subtitles", 'center')

        playSound("spin", 1, "spin")
    end
end

function onGameOverConfirm(retry)
        if retry then
            playAnim("bfGameOver", "confirm", true, false, 0)
            playSound("bfConfirm", 1)
            soundFadeOut("tryAgain", 0.3)
            pauseSound("drowning")
            cancelTimer("tickTock")
            cancelTimer("doVoiceLine")
            stopSound("voiceLine")
            setProperty("subtitles.visible", false)

            doTweenX("try", "try", -230*3.25, 0.3, "linear")
            doTweenX("again", "again", 230*3.25, 0.3, "linear")
            doTweenAlpha("eyes", "eyes", 0, 0.3, "quadOut")

            runTimer("fadeOut", 1)
            runTimer("jiggleTime", 0.2)

            startcounting = false
            hasRetried = true
            doTweenAlpha("countdown", "countdown", 0, 0.3, "quadOut")
        else 
            stopSound("drowning")
            stopSound("voiceLine")
            stopSound("tryAgain")
        end
end

function onUpdate(elapsed)
        eyeShake = getProperty("eyesShakeVar.x")
        eyeShakeSpeed = getProperty("eyesShakeSpeedVar.x")

        if startcounting == true then
            countdowntime = math.floor(timer/2)
        end

        if countdowntime >= 10 then
            setTextString("countdown", 10)
        else
            setTextString("countdown", '0'..countdowntime)
        end

        for i = 1,9 do
            if countdowntime == i and nextnumber == countdowntime then
                scaleObject("countdown", 1.25, 1.25)
                setProperty("countdown.x", 550)
                setProperty("countdown.y", 210)
                doTweenX("countdownScale1", "countdown.scale", 1, 0.5, "quadOut")
                doTweenY("countdownScale2", "countdown.scale", 1, 0.5, "quadOut")

                setPropertyFromClass('openfl.Lib', 'application.window.title', i)

                nextnumber = nextnumber - 1
            end
        end

        if countdowntime == 0 then
            startcounting = false
        end

        if startcounting then
            timer = timer - elapsed
            if countdowntime ~= 0 and keyJustPressed('accept') then
                startcounting = false
            end
        end

        if defeat then
            if keyJustPressed("accept") then
                playSound("confirmMenu", 1, "confirmMenu")
                soundFadeOut("defeat", 0.3)
        
                cancelTimer("flash1")
                runTimer('flash2', 0.05, 99)
                runTimer('fadeOut', 0.25)
                runTimer("exitSong", 1)

                defeat = false
            end
        end
end

function onTweenCompleted(tag)
    if tag == 'eyesShake1' then
        doTweenX("eyesShake2", "eyes", 230+eyeShake, eyeShakeSpeed, "linear")
    end

    if tag == 'eyesShake2' then
        doTweenX("eyesShake1", "eyes", 230-eyeShake, eyeShakeSpeed, "linear")
    end

    if tag == 'tryColor' then
        doTweenAlpha("tryBye", "try", 0, 0.3, "sineOut")
        doTweenAlpha("again2", "again", 0, 0.3, "sineOut")
    end
end

function doSubtitles(text)
    setTextString("subtitles", text)
    setProperty("subtitles.alpha", 1)

    if text == "どんどん進んで！" or text == "地獄じゃ未来、眩しくねぇな" then
        setTextFont("subtitles", "nosutaru.ttf")
    end
end

function onTimerCompleted(tag, loops, loopsLeft)

    --COUNTDOWN STUFF
    if tag == 'start' then
        runTimer('startCount', 0.75)
        doTweenAlpha("countdown", "countdown", 1, 0.75, "linear")
        setPropertyFromClass('openfl.Lib', 'application.window.title', "10")
    end

    if tag == 'startCount' then
        startcounting = true
    end

    if tag == 'countdownTimer' then
        for i = 1,9 do
            if countdowntime == i then
                scaleObject("countdown", 1.5, 1.5)
                doTweenX("countdownScale1", "countdown.scale", 1, 0.5, "quadOut")
                doTweenY("countdownScale2", "countdown.scale", 1, 0.5, "quadOut")
            end
        end
    end
    --COUNTDOWN STUFF

    if tag == 'jiggleTime' then
        runTimer("jiggle", 0.05, 4) -- just so i can set the timing for this properly lol
    end

    if tag == 'jiggle' then
        if loopsLeft ~= 0 then
            if loopsLeft % 2 == 0 then
                doTweenX("jiggle", "bfGameOver", 215, 0.05, "linear")
            else
                doTweenX("jiggle", "bfGameOver", 245, 0.05, "linear")
            end
        else
            doTweenX("jiggle", "bfGameOver", 230, 0.025, "linear")
        end
    end

    if tag == 'tryAgain' then
        doTweenX("try", "try", 230, 1.0, "bounceOut")
        doTweenX("again", "again", 230, 1.0, "bounceOut")
    end

    if tag == 'wompwomp' then
        playSound("tuhDuh", 1, "tuhDuh")
        setPropertyFromClass('openfl.Lib', 'application.window.title', "TRY AGAIN")
    end

    if tag == 'deadTrack' then
        playSound("tryAgain", 1, "tryAgain")
        setProperty("isEnding", false)

        runTimer('tickTock', 10)
        runTimer('doVoiceLine', 1)
    end

    if tag == "doVoiceLine" then
        line = getRandomInt(0, maxLines)
        playSound("gameOverLines/"..curCharacter.."/"..line, 1, "voiceLine")
        soundFadeOut("tryAgain", 0.175, 0.35)

        if curCharacter == "LordX" then lordXSubtitles[line]() end
        if curCharacter == "X" then XSubtitles[line]() end
        if curCharacter == "Majin" then majinSubtitles[line]() end
        if curCharacter == "SonicTGE" then sonicTGESubtitles[line]() end
        if curCharacter == "SonicTGEMidareta" then sonicTGEMidaretaSubtitles[line]() end
        if curCharacter == "SonicTrinity" then sonicTrinitySubtitles[line]() end
        if curCharacter == "Fusion" then fusionSubtitles[line]() end
    end

    if tag == 'tickTock' then
        playSound("drowning", 1, "drowning")
        doTweenColor("tryColor", "try", "FF0000", 6.0, "linear")
        doTweenColor("again", "again", "FF0000", 6.0, "linear")
        doTweenAlpha("eyes", "eyes", 0.3, 25.75, "quintIn")
        doTweenX("eyesShakeMoment", "eyesShakeVar", 15, 25, "linear")
        doTweenX("speeed", "eyesShakeSpeedVar", 0.02, 25, "linear")
        runTimer('start', 6.4)
        setPropertyFromClass('openfl.Lib', 'application.window.title', "")
    end

    if tag == 'timesUp' then
        playSound("death", 1, "death")
        runTimer('byeBye', 0.85)
    end

    if tag == 'byeBye' then
        playAnim("bfGameOver", "death", true, false, 0)
        runTimer('jumpscare', 0.25)
    end

    if tag == 'jumpscare' then
        setPropertyFromClass('openfl.Lib', 'application.window.title', "")
        removeLuaText("countdown")
        removeLuaSprite('bfGameOver')
        playAnim("jumpscare", "jumpscare", true, false, 0)
        setProperty("jumpscare.alpha", 1)
    end

    if tag == 'defeat' then
        playSound("defeat", 1, "defeat")
        doTweenX("defeat", "defeat", 230, 0.5, "linear")
        runTimer('allowMenuInput', 5)
    end

    if tag == 'allowMenuInput' then
        makeLuaSprite("pressSpace", "pressSpace", 256, 0)
        scaleObject("pressSpace", 3.0, 3.0)
        addLuaSprite("pressSpace")
        setProperty('pressSpace.antialiasing', false)
        setObjectCamera('pressSpace', 'other')

        defeat = true

        runTimer('flash1', 0.5, 99)
    end

    if tag == 'flash1' then
        if loopsLeft % 2 == 0 then
            setProperty("pressSpace.visible", false)
        else
            setProperty("pressSpace.visible", true)
        end

        if loopsLeft == 1 then
            runTimer('flash1', 0.5, 98)
        end
    end
    
    if tag == 'flash2' then
        if loopsLeft % 2 == 0 then
            setProperty("pressSpace.visible", false)
        else
            setProperty("pressSpace.visible", true)
        end
    end

    if tag == 'fadeOut' then
        makeLuaSprite("blue", 0, 0)
        makeGraphic('blue', 1280, 720, '0000FF')
        setScrollFactor('blue', 0, 0)
        setObjectCamera('blue', 'other')
        setProperty('blue.antialiasing', false)
        addLuaSprite('blue',true)
        setBlendMode("blue", 'multiply')
        setProperty('blue.alpha', 0.0)

        doTweenAlpha("blue", "blue", 1, 0.3, "sineOut")
        cameraFade("other", "000000", 0.5, 'linear')
    end

    if tag == 'exitSong' then
        exitSong(false)
    end

    -- subtitles

    if tag == "lordX0" then
        doSubtitles("BUT FOR YOU, I AM THE LAST.")
    end

    if tag == "2011X0" then
        doSubtitles("BUT I'M STILL THE SAME")
    end

    if tag == "2011X3" then
        doSubtitles("AND YOU CAN'T HIDE")
    end

    if tag == "2011X4" then
        doSubtitles("A SONIC LEGACY")
    end

    if tag == "2011X4-2" then
        doSubtitles("A SONIC LEGACY... FNF")
    end

    if tag == "2011X5" then
        doSubtitles("WOULDN'T YOU AGREE?")
    end

    if tag == "2011X9" then
        doSubtitles("FROM A FATE YOU WON'T ESCAPE")
    end

    if tag == "majin7" then
        doSubtitles("WHAT A SHAME...")
    end

    if tag == "sonicTrinity1" then
        doSubtitles("DON'T FEEL BAD!\nI KNOW YOU'RE TRYING... AREN'T YOU?")
    end

    if tag == "sonicTrinity5" then
        doSubtitles("SO MANY GAMES TO PLAY...\nSO LITTLE TIME.")
    end

    if tag == "sonicTrinity6" then
        doSubtitles("YOU KNOW MY NATURE,\nAND I KNOW YOURS!")
    end

    if tag == "sonicTrinity7" or tag == "fusion0" then
        doSubtitles("")
    end

    if tag == "fusion0-1" then
        doSubtitles("READY FOR ROUND 2?")
    end

    if tag == "fusion1" then
        doSubtitles("SO LITTLE TIME...")
    end

    if tag == "fusion2" then
        doSubtitles("I AM GOD!")
    end

    if tag == "fusion3" then
        doSubtitles("HO HO HO HO HO HO HO HO!")
    end
end

function onSoundFinished(tag)
    if tag == 'drowning' then
        setProperty("isEnding", true)
        removeLuaSprite('bgGameOver')
        removeLuaSprite('eyes')
        playAnim("bfGameOver", "deathFrame", true, false, 0)
        playSound("jumpSound", 1, "jumpSound")
        runTimer('timesUp', 1)
        setPropertyFromClass('openfl.Lib', 'application.window.title', "Got You~!")
    end

    if tag == 'death' then
        runTimer('defeat', 1)
        removeLuaSprite("jumpscare")
    end

    if tag == "voiceLine" and not hasRetried then
        soundFadeOut("tryAgain", 0.15, 1)
        doTweenAlpha("subtitleTween", "subtitles", 0.001, 0.2, "linear")
    end
end

function onStepHit()
    if curStep == 1176 then curCharacter = "Fusion" end
    if curStep == 4528 then noMoreDeath = true end -- have to have this var here too otherwise it's gonna activate some of the code still
end

function onDestroy()
    
end