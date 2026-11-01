-- CUSTOM SUBSTATE MOMENT WOOOO`

local canReset = false
local lockedIn = false
local firstDeathAnim = false

function onCreate()
    openCustomSubstate('FPGameOver', false)

    makeLuaBackdrop("scrollingBG", "blueCloudsScary", "XY", 0, 0)
    setObjectOrder("scrollingBG", 7)
    setProperty("scrollingBG.alpha", 0.001)
    scaleObject("scrollingBG", 2, 2)
    setProperty("scrollingBG.antialiasing", false)
    setProperty('scrollingBG.velocity.x', -150)
    setProperty('scrollingBG.velocity.y', -100)
    addLuaBackdrop("scrollingBG")
end

function onCustomSubstateCreate(name)
    if name == 'FPGameOver' then
        setProperty('canPause', false)
        runHaxeCode('game.persistentUpdate = true;') -- lets anims play on custom substate lol!

        doTweenAlpha('trippyBG', 'trippyBG', 0, 1.3, 'quadIn')
        doTweenAlpha('trippyBGInvert', 'trippyBGInvert', 0, 1.3, 'quadIn')
        doTweenAlpha('remixBG', 'remixBG', 0, 1.3, 'quadIn')
        doTweenAlpha('camHUD', 'camHUD', 0, 1.3, 'quadIn')
        doTweenAlpha('bgDark', 'bgDark', 0, 1.3, 'quadIn')
        doTweenColor('bg', 'bg', '00000E', 2.5, 'quadIn')
        setProperty('SEGA.visible', false)

        triggerEvent('CameraZoom', '1', '1')
        
        runHaxeCode([[
            FlxTween.tween(FlxG.sound.music, {volume: 0}, 0.75);
            FlxTween.tween(opponentVocals, {volume: 0}, 0.5);
            FlxTween.tween(vocals, {volume: 0}, 0.5);
        ]]);

        runTimer('canReset', 3.3)
    end
end

function onCustomSubstateCreatePost(name)
    if name == 'FPGameOver' then
        playSound('collect', 1, 'collect')
        triggerEvent('Play Animation', 'firstDeath', 'dad')
    end
end

function onCustomSubstateUpdate(name, elapsed)
    if name == 'FPGameOver' then
        setPropertyFromClass('backend.Conductor', 'songPosition', 0)

        if canReset then
            if keyJustPressed("accept") and not lockedIn then
                runTimer('restartSong', 2)
                runHaxeCode('FlxG.sound.music.stop();')
                playSound('confirmLaugh', 1, 'confirmLaugh')
                triggerEvent('Play Animation', 'deathConfirm', 'dad')
                runHaxeCode('game.persistentUpdate = false;')
                setPropertyFromClass('openfl.Lib', 'application.window.title', "LET'S PLAY AGAIN!")
                runTimer('byeSonic', 0.1)
                lockedIn = true
            end

            if keyJustPressed("back") and not lockedIn then
                setProperty('dad.visible', false)
                runHaxeCode('FlxG.sound.music.stop();')
                playSound('jumpSound', 1, 'jumpSound')
                setProperty('scrollingBG.visible', false)
                runHaxeCode('game.persistentUpdate = false;')
                setPropertyFromClass('openfl.Lib', 'application.window.title', "BETTER LUCK NEXT TIME~")
                runTimer('fadeOut', 0.5)
                runTimer('endSong', 1.25)
                lockedIn = true
            end
        end

        if getProperty('dad.animation.curAnim.finished') then
            if getProperty('dad.animation.curAnim.name') == 'firstDeath' and not firstDeathAnim then
                triggerEvent('Play Animation', 'deathLoop', 'dad')
                setProperty('defaultCamZoom', 0.9)
                firstDeathAnim = true
            end
        end
    end
end

function onTweenCompleted(tag)
    if tag == 'trippyBG' then
        setProperty('trippyBG.visible', false)
        setProperty('trippyBGInvert.visible', false)
        setProperty('remixBG.visible', false)
        setProperty('camHUD.visible', false)
        setProperty('bgDark.visible', false)
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == 'canReset' then
        canReset = true
        playMusic('gameOver', 1, true)
        doTweenAlpha('scrollingBG', 'scrollingBG', 1, 1.5, 'quadInOut')
    end

    if tag == 'byeSonic' then
        setProperty('dad.visible', false)
        setProperty('scrollingBG.visible', false)
        runTimer('fadeOut', 0.5)
    end

    if tag == 'fadeOut' then
        cameraFade('camOther', '000000', 0.75, true)
    end

    if tag == 'endSong' then
        exitSong()
    end
end

function onSoundFinished(tag)
    if tag == 'confirmLaugh' then
        restartSong() -- dont set to true, game crashes lol, probably doesnt know how to transition
    end
end