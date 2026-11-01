-- i robbed 90% of the code from the original game over, lazyyy!! -snow

local eyeShake = 20
local eyeShakeSpeed = 0.1

local defeat = false

local timer = 21.7
local startcounting = false
local hasRetried = false
local countdowntime = 10
local nextnumber = 9

local windowOriginX = 0
local windowOriginY = 0

local centerScreen = false

-- STEALING THE COUNTDOWN CODE FROM MY PENDRIVE MOD TEEHEE

function onCreate()
    makeLuaSprite("eyesShakeVar", 0, 0)
    setProperty("eyesShakeVar.x", 0)

    makeLuaSprite("eyesShakeSpeedVar", 0.2, 0)
    setProperty("eyesShakeSpeedVar.x", 0.2)
end

function onCreatePost()

end

function onGameOverStart()
    if not noMoreDeath then
        setPropertyFromClass('openfl.Lib', 'application.window.title', "")
        setPropertyFromClass('openfl.Lib', 'application.window.opacity', 1)

        setProperty("isEnding", true) -- basically if true, locks the input until the player is allowed to reset (it does more than that tbf, but in this case it's what i'll be doing to lock the input)

        runTimer('tryAgain', 1.5)
        runTimer('wompwomp', 1.8)
        runTimer('deadTrack', 2.5)

        makeLuaSprite('bg', '', -500, -500)
        makeGraphic('bg', 1, 1, '100410')
        scaleObject('bg', 2500, 2000)
        setScrollFactor('bg', 0, 0)
        addLuaSprite('bg',false)

        makeAnimatedLuaSprite("gameOverChar", "gameOver/sonicKyokaiGO", -10, 0)
        addAnimationByPrefix('gameOverChar', 'loss', 'FIRSTdeath', 30, false)
        addAnimationByPrefix('gameOverChar', 'idle', 'IDLE', 1, false)
        addAnimationByPrefix('gameOverChar', 'confirm', 'CONFIRM', 30, false)
        addAnimationByPrefix('gameOverChar', 'defeat', 'DEFEAT', 30, false)
        addAnimationByPrefix('gameOverChar', 'countdownEnd', 'COUNTDOWNEND', 1, false)
        playAnim("gameOverChar", "loss", true, false, 0)
        setProperty("gameOverChar.antialiasing", false)
        scaleObject("gameOverChar", 3.25, 3.25)
        setObjectCamera("gameOverChar", 'other')
        addLuaSprite("gameOverChar", false)

        makeLuaSprite("try", "gameOver/try", -230*4, -100)
        setProperty("try.antialiasing", false)
        scaleObject("try", 3.25, 3.25)
        setObjectCamera("try", 'other')
        addLuaSprite("try", false)

        makeLuaSprite("again", "gameOver/again", 230*4, -100)
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

        makeLuaSprite("iAmGodScreamer", "iAmGodKyokai", 0, 0)
        setProperty("iAmGodScreamer.antialiasing", false)
        setObjectCamera('iAmGodScreamer', 'other')
        setGraphicSize('iAmGodScreamer', 1280, 720)
        setProperty("iAmGodScreamer.alpha", 0.0001)
        addLuaSprite('iAmGodScreamer', false)

        playSound("FirstDeath", 1, "FirstDeath")
    end
end

function onGameOverConfirm(retry)
        if retry then
            playAnim("gameOverChar", "confirm", true, false, 0)
            playSound("bfConfirm", 1)
            soundFadeOut("tryAgain", 0.3)
            pauseSound("drowning")
            cancelTimer("tickTock")
            cancelTimer("doVoiceLine")
            stopSound("voiceLine")
            setProperty("subtitles.visible", false)

            doTweenX("try", "try", -230*4, 0.3, "linear")
            doTweenX("again", "again", 230*4, 0.3, "linear")
            doTweenAlpha("eyes", "eyes", 0, 0.3, "quadOut")

            runTimer("fadeOut", 1)
            runTimer("jiggleTime", 0.25)
            runTimer("clap", 0.75)

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

    if centerScreen then
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
        ]]); -- this centers the window to the monitor it's on
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

    if tag == 'tryAgain' then
        doTweenX("try", "try", 230, 1.0, "bounceOut")
        doTweenX("again", "again", 230, 1.0, "bounceOut")
    end

    if tag == 'wompwomp' then
        setPropertyFromClass('openfl.Lib', 'application.window.title', "TRY AGAIN")
    end

    if tag == 'deadTrack' then
        playSound("MusicGO", 1, "tryAgain")
        setProperty("isEnding", false)

        runTimer('tickTock', 10)
        runTimer('doVoiceLine', 1)
    end

    if tag == 'tickTock' then
        playSound("drowning", 1, "drowning")
        soundFadeOut("tryAgain", 0.3)
        doTweenColor("tryColor", "try", "FF0000", 6.0, "linear")
        doTweenColor("again", "again", "FF0000", 6.0, "linear")
        doTweenAlpha("eyes", "eyes", 0.3, 25.75, "quintIn")
        doTweenX("eyesShakeMoment", "eyesShakeVar", 15, 25, "linear")
        doTweenX("speeed", "eyesShakeSpeedVar", 0.02, 25, "linear")
        runTimer('start', 6.4)
        setPropertyFromClass('openfl.Lib', 'application.window.title', "")
    end

    if tag == 'timesUp' then
        runTimer('byeBye', 0.85)
    end

    if tag == 'byeBye' then
        playAnim("gameOverChar", "defeat", true, false, 0)
        playSound('Boo', 1, 'Boo')
        runTimer('jumpscare', 0.15)
    end

    if tag == 'jumpscare' then
        setPropertyFromClass('openfl.Lib', 'application.window.title', "")
        removeLuaText("countdown")
        setProperty("iAmGodScreamer.alpha", 1)
        if flashingLights then
            runTimer('scarySonicColor1', 0.03)
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

        centerScreen = false

        doTweenAlpha("blue", "blue", 1, 0.3, "sineOut")
        cameraFade("other", "000000", 0.5, 'linear')
    end

    if tag == "scarySonicColor0" then
        doTweenColor('scaryScreamerColor', 'iAmGodScreamer', 'FFFFFF', 0.001, 'linear')
        runTimer("scarySonicColor1", 0.03)
        setProperty('iAmGodScreamer.x', -10)
    end

    if tag == 'scarySonicColor1' then
        doTweenColor('scaryScreamerColor', 'iAmGodScreamer', 'BCBCBC', 0.001, 'linear')
        runTimer("scarySonicColor2", 0.03)
    end

    if tag == "scarySonicColor2" then
        doTweenColor('scaryScreamerColor', 'iAmGodScreamer', '969696', 0.001, 'linear')
        runTimer("scarySonicColor0", 0.03)
        setProperty('iAmGodScreamer.x', 10)
    end

    if tag == "clap" then
        playSound('HandGrab', 1, 'HandGrab')
        centerScreen = true
        doTweenWindow('16:9', 'width', 1280, 0.2,'quadOut',1)
        doTweenWindow('16:9 (2)', 'height', 720, 0.2,'quadOut',1)
    end
end

function onSoundFinished(tag)
    if tag == 'drowning' then
        setProperty("isEnding", true)
        removeLuaSprite('eyes')
        playAnim("gameOverChar", "countdownEnd", true, false, 0)
        playSound("jumpSound", 1, "jumpSound")
        runTimer('timesUp', 1)
        setPropertyFromClass('openfl.Lib', 'application.window.title', "Got You~!")
    end

    if tag == 'Boo' then
        triggerEvent('Restore Taskbar', nil, nil)
        os.exit()
    end
end

function doTweenWindow(tag,var,value,duration,ease,types)
	-- allows the window to be tweened, works with resizing windows too :D

        cancelTween(tag) -- reduces chance of it duplicating and breaking

        runHaxeCode([[
        game.modchartTweens.set(']]..tag..[[',
            FlxTween.tween(Lib.application.window,
                {]]..var..[[: ]]..value..[[},
                ]]..duration..[[,
                {ease: FlxEase.]]..ease..[[,
                type: ]]..types..[[
            })
        );
        ]])
end


function onDestroy()
    
end