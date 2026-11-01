-- internal x moment

local stopTimerLoopingIdiot = false

local defeat = false

local timer = 21.7
local startcounting = false
local hasRetried = false
local countdowntime = 10
local nextnumber = 9

local wagFrame = 0

function onGameOverStart()
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

    playSound("internalXVanish", 1)

    makeAnimatedLuaSprite("intXGameOver", "gameOver/internalXGameOver", 230, 0)
    addAnimationByPrefix('intXGameOver', 'intro', 'intro', 15, false)
    addAnimationByPrefix('intXGameOver', 'appear', 'appear', 15, false)
    addAnimationByPrefix('intXGameOver', 'bye', 'appear', 15, false)
    addAnimationByPrefix('intXGameOver', 'loop', 'loop', 5, true)
    addAnimationByPrefix('intXGameOver', 'end', 'end', 20, false)
    addAnimationByPrefix('intXGameOver', 'freezeframe', 'intro', 1, false)
    playAnim("intXGameOver", "intro", true, false, 0)
    setProperty("intXGameOver.antialiasing", false)
    scaleObject("intXGameOver", 3.25, 3.25)
    setObjectCamera("intXGameOver", 'other')
    addLuaSprite("intXGameOver", false)

    makeLuaText("countdown", "10", 150, 565, 220)
    setTextSize("countdown", 6*8)
    setScrollFactor('countdown', 0,0)
    setObjectCamera('countdown', 'other')
    setTextColor("countdown", "0000FF")
    addLuaText("countdown")
    setTextAlignment("countdown", 'center')
    setTextFont("countdown", "sonicCD.ttf")
    setTextBorder("countdown", 0)
    setProperty('countdown.alpha',0)
    setProperty('countdown.antialiasing', false)

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
    setProperty("bfGameOver.alpha", 0.001)

    makeAnimatedLuaSprite("jumpscare", "gameOver/jumpscareGameOver", 230, 0)
    addAnimationByPrefix('jumpscare', 'jumpscare', 'jumpscare', 30, false)
    addAnimationByPrefix('jumpscare', 'jumpscare2', 'jumpscare', 30, false)
    playAnim("jumpscare", "jumpscare2", true, false, 0)
    setProperty("jumpscare.antialiasing", false)
    scaleObject("jumpscare", 3.25, 3.25)
    setObjectCamera("jumpscare", 'other')
    addLuaSprite("jumpscare", false)
    setProperty("jumpscare.alpha", 0.001)

    makeAnimatedLuaSprite("lordXCountdown1", "gameOver/lordXCountdown", 300, 130)
    addAnimationByPrefix('lordXCountdown1', 'slow', 'lordXCountdown', 5, true)
    addAnimationByPrefix('lordXCountdown1', 'normal', 'lordXCountdown', 10, true)
    addAnimationByPrefix('lordXCountdown1', 'fast', 'lordXCountdown', 15, true)
    addAnimationByPrefix('lordXCountdown1', 'speed', 'lordXCountdown', 20, true)
    playAnim("lordXCountdown1", "slow", true, false, 0)
    setProperty("lordXCountdown1.antialiasing", false)
    scaleObject("lordXCountdown1", 3, 3)
    setObjectCamera("lordXCountdown1", 'other')
    addLuaSprite("lordXCountdown1", false)
    setProperty("lordXCountdown1.alpha", 0.001)

    makeAnimatedLuaSprite("lordXCountdown2", "gameOver/lordXCountdown", 710, 130)
    addAnimationByPrefix('lordXCountdown2', 'slow', 'lordXCountdown', 5, true)
    addAnimationByPrefix('lordXCountdown2', 'normal', 'lordXCountdown', 10, true)
    addAnimationByPrefix('lordXCountdown2', 'fast', 'lordXCountdown', 15, true)
    addAnimationByPrefix('lordXCountdown2', 'speed', 'lordXCountdown', 20, true)
    playAnim("lordXCountdown2", "slow", true, false, 0)
    setProperty("lordXCountdown2.antialiasing", false)
    scaleObject("lordXCountdown2", 3, 3)
    setObjectCamera("lordXCountdown2", 'other')
    addLuaSprite("lordXCountdown2", false)
    setProperty("lordXCountdown2.alpha", 0.001)

    makeLuaSprite("defeat", "gameOver/defeat", -230*3.25, 0)
    setProperty("defeat.antialiasing", false)
    scaleObject("defeat", 3.25, 3.25)
    setObjectCamera("defeat", 'other')
    addLuaSprite("defeat", false)

    runTimer("appear", 1.5)
end


function onUpdate(elapsed)
    if getProperty('intXGameOver.animation.curAnim.finished') then
        if getProperty('intXGameOver.animation.curAnim.name') == 'appear' and not stopTimerLoopingIdiot then
            playAnim("intXGameOver", "loop", true, false, 0)
            setProperty("isEnding", false)
            runTimer('tickTock', 7)
            stopTimerLoopingIdiot = true
        end

        if getProperty('intXGameOver.animation.curAnim.name') == 'bye' then
            playAnim("intXGameOver", "freezeframe", true, false, 8)
        end

        if getProperty('intXGameOver.animation.curAnim.name') == 'end' then
            setProperty("intXGameOver.visible", false)
        end
    end

    wagFrame = getProperty("lordXCountdown1.animation.curAnim.curFrame")

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

    if countdowntime == 7 then
        playAnim("lordXCountdown1", "normal", false, false, 0)
        playAnim("lordXCountdown2", "normal", false, false, 0)
    end

    if countdowntime == 3 then
        playAnim("lordXCountdown1", "fast", false, false, 0)
        playAnim("lordXCountdown2", "fast", false, false, 0)
    end

    if countdowntime == 1 then
        playAnim("lordXCountdown1", "speed", false, false, 0)
        playAnim("lordXCountdown2", "speed", false, false, 0)
    end

    if countdowntime == 0 then
        startcounting = false

        playAnim("lordXCountdown1", "slow", false, false, 0)
        playAnim("lordXCountdown2", "slow", false, false, 0)
        setProperty('lordXCountdown1.animation.curAnim.paused', true)
        setProperty('lordXCountdown2.animation.curAnim.paused', true)
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

function onGameOverConfirm(retry)
    if retry then
        if getProperty('intXGameOver.animation.curAnim.name') == 'bye' or getProperty('intXGameOver.animation.curAnim.name') == 'freezeframe' then
            --nothing!!!!
        else
            playAnim("intXGameOver", "end", true, false, 0)
            playSound("internalXConfirm", 1)
        end
        soundFadeOut("loopMusic", 1.25)
        pauseSound("drowning")
        cancelTimer("tickTock")
        runTimer("fadeOut", 1)
        runTimer("jiggleTime", 0.2)
        startcounting = false
        hasRetried = true
        doTweenAlpha("countdown", "countdown", 0, 0.3, "quadOut")
        doTweenAlpha("lordXCountdown1", "lordXCountdown1", 0, 0.3, "quadOut")
        doTweenAlpha("lordXCountdown2", "lordXCountdown2", 0, 0.3, "quadOut")
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

            doTweenAlpha("lordXCountdown1", "lordXCountdown1", 1, 0.75, "linear")
            doTweenAlpha("lordXCountdown2", "lordXCountdown2", 1, 0.75, "linear")
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

    if tag == 'appear' then
        playAnim("intXGameOver", "appear", true, false, 0)
        playSound("internalXGameOverLoop", 1, "loopMusic")
    end

    if tag == 'tickTock' then
        playSound("drowning", 1, "drowning")
        runTimer('start', 6.4)
        playAnim("intXGameOver", "bye", true, true, 0)
        soundFadeOut("loopMusic", 0.3)
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
        setProperty("lordXCountdown1.visible", false)
        setProperty("lordXCountdown2.visible", false)
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
end

function onSoundFinished(tag)
    if tag == 'drowning' then
        setProperty("isEnding", true)
        removeLuaSprite('bgGameOver')
        removeLuaSprite('eyes')
        setProperty("bfGameOver.alpha", 1)
        playAnim("bfGameOver", "deathFrame", true, false, 0)
        playSound("jumpSound", 1, "jumpSound")
        runTimer('timesUp', 1)
        setPropertyFromClass('openfl.Lib', 'application.window.title', "Got You~!")
    end

    if tag == 'death' then
        runTimer('defeat', 1)
        removeLuaSprite("jumpscare")
    end
end