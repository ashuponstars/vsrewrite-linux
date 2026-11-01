--test by snow

local finish = false
local deaths = 1

local victoryActive = false

local STOPFUCKINGLOOPINGDUMBASS = false

local highestCombo = 0

local bgUpdate = false
local bfUpdate = false

local jumpyBoi = false

function onCreate()
    --debugPrint(getPropertyFromClass("states.PlayState", "deathCounter")+1)
    deaths = getPropertyFromClass("states.PlayState", "deathCounter") + 1

    makeLuaSprite("black", '', 0, 0)
    makeGraphic('black', 2000, 1000, '000000')
    setScrollFactor('black', 0, 0)
    setObjectCamera('black', 'other')
    setProperty('black.antialiasing', false)
    addLuaSprite('black',false)
    setProperty('black.alpha', 0.0001)
    
    if songName ~= 'Trinity' then
        makeAnimatedLuaSprite("victoryBG", "victoryScreen", 230, 0)
        addAnimationByPrefix('victoryBG', 'temp', 'STARTBG', 30, false)
        addAnimationByPrefix('victoryBG', 'startAnim', 'STARTBG', 30, false)
        addAnimationByPrefix('victoryBG', 'bg', 'BG0', 30, false)
        playAnim("victoryBG", "temp", false, false, 0)
        setProperty("victoryBG.antialiasing", false)
        setProperty('victoryBG.alpha', 0.001)
        scaleObject("victoryBG", 3.22, 3.22)
        setObjectCamera("victoryBG", 'other')
        addLuaSprite("victoryBG", false)

        makeAnimatedLuaSprite("victoryBF", "victoryScreen", 230, 0)

        addAnimationByPrefix('victoryBF', 'temp', 'bfSTART', 30, false)
        addAnimationByPrefix('victoryBF', 'startAnimation', 'bfSTART', 30, false)
        addAnimationByPrefix('victoryBF', 'loopAnim', 'LOOP0', 30, true)
        addAnimationByPrefix('victoryBF', 'jump', 'JUMP0', 30, false)

        playAnim("victoryBF", "temp", false, false, 0)
        setProperty("victoryBF.antialiasing", false)
        setProperty('victoryBF.alpha', 0.001)
        scaleObject("victoryBF", 3.22, 3.22)
        setObjectCamera("victoryBF", 'other')
        addLuaSprite("victoryBF", false)
    end

    makeLuaSprite("white", '', 0, 0)
    makeGraphic('white', 2000, 1000, 'FFFFFF')
    setScrollFactor('white', 0, 0)
    setObjectCamera('white', 'other')
    setProperty('white.antialiasing', false)
    addLuaSprite('white',false)
    setProperty('white.alpha', 0.0001)

    makeLuaSprite("whiteGame", '', -1000, -1000)
    makeGraphic('whiteGame', 3000, 2000, 'FFFFFF')
    setScrollFactor('whiteGame', 0, 0)
    setProperty('whiteGame.antialiasing', false)
    addLuaSprite('whiteGame',true)
    setProperty('whiteGame.alpha', 0.0001)

    -- figured i'd move these on create so it wouldn't lag
end

function onUpdate(elapsed)
    if victoryActive then
        setPropertyFromClass('backend.Conductor', 'songPosition', 0)
    elseif keyJustPressed("accept") then
        --endSong() -- stupid debug thing im keeping in for now in case i need to test around with it more
    end

    if finish then
        if keyJustPressed("accept") then
            if not STOPFUCKINGLOOPINGDUMBASS then
                playSound("confirmMenu", 1, "confirmMenu")

                cancelTimer("flash1")
                runTimer('flash2', 0.05, 99)
                runTimer('fadeBlack', 0.25)
                STOPFUCKINGLOOPINGDUMBASS = true
            end
        end
    end

    if songName ~= 'Trinity' then
        if getProperty('victoryBG.animation.curAnim.finished') then
            if getProperty('victoryBG.animation.curAnim.name') == 'startAnim' and not bgUpdate then
                playAnim("victoryBG", "bg", false, false, 0)
                bgUpdate = true
            end
        end
        
        if getProperty('victoryBF.animation.curAnim.finished') then
            if getProperty('victoryBF.animation.curAnim.name') == 'startAnimation' and not bfUpdate then
                playAnim("victoryBF", "loopAnim", false, false, 0)
                runTimer('jumpyBoi', getRandomFloat(3, 7))
                bfUpdate = true
            end
        end

        if getProperty('victoryBF.animation.curAnim.finished') then
            if getProperty('victoryBF.animation.curAnim.name') == 'jump' and not jumpyBoi then
                playAnim("victoryBF", "loopAnim", false, false, 0)
                runTimer('jumpyBoi', getRandomFloat(3, 6))
                jumpyBoi = true
            end
        end
    end
end

function onUpdatePost(elapsed)
    if combo > highestCombo then
        highestCombo = combo
    end
end

function onEndSong()
    if getVar('lockEnd') ~= true then
        if not finish then
            runTimer("flashbang", 0.1, 10)

            runTimer("fadeWhite", 1.5)
            playSound("victoryRing", 1, "victoryRing")
            victoryActive = true

            if songName == 'Thriller Gen' then
                runHaxeCode([[
                    FlxG.save.data.beatenTG = true;
                    FlxG.save.flush();
                ]])
            end

            if songName == 'Trinity' then
                runHaxeCode([[
                    FlxG.save.data.beatenTrinity = true;
                    FlxG.save.flush();
                ]])
            end

            return Function_Stop;
        else
            return Function_Continue;
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)

    if tag == 'jumpyBoi' then
        playAnim("victoryBF", "jump", false, false, 0)
        jumpyBoi = false
    end

    if tag == 'flashbang' then
        setProperty("whiteGame.alpha", getProperty("whiteGame.alpha") + 0.1)
    end

    if tag == 'fadeWhite' then
        doTweenAlpha("white", "white", 1, 0.25, "quadOut")
        runTimer("startScreen", 0.75)
    end

    if tag == 'startScreen' then
        if songName ~= 'Trinity' then
            setProperty('victoryBG.alpha', 1)
            setProperty('victoryBF.alpha', 1)
            playAnim("victoryBG", "startAnim", false, false, 0)
            playAnim("victoryBF", "startAnimation", false, false, 0)
        end

        makeAnimatedLuaSprite("Victory", 'victory', -768, 0)
        addAnimationByPrefix("Victory", "victory", "victory", 12, true)
        addLuaSprite("Victory")
        setProperty('Victory.antialiasing', false)
        scaleObject("Victory", 3.0, 3.0)
        screenCenter("Victory", 'Y')
        setObjectCamera('Victory', 'other')

        makeAnimatedLuaSprite("Sparkle", 'sparkle', -768 + 120, 0)
        addAnimationByPrefix("Sparkle", "sparkle", "sparkle", 24, true)
        addLuaSprite("Sparkle")
        setProperty('Sparkle.antialiasing', false)
        screenCenter("Sparkle", 'Y')
        setObjectCamera('Sparkle', 'other')

        setProperty("camHUD.visible", false)

        for i = 4,7 do
            setPropertyFromGroup('strumLineNotes', i, 'alpha', 0) -- for camNotes on Trinity
        end

        setProperty("whiteGame.alpha", 0)
        setProperty("black.alpha", 0.75)
        doTweenAlpha("white", "white", 0, 0.5, "quadOut")     

        doTweenX("Victory", "Victory", 256, 0.5, "linear")
        doTweenX("Sparkle", "Sparkle", 256 + 120, 0.5, "linear")

        runTimer("enable", 6)

        runTimer("byeVictory", 5.2)
        playSound('Victory', 1, 'Victory')
    end

    if tag == 'byeVictory' then
        doTweenX("Victory", "Victory", -768, 0.5, "linear")
        doTweenX("Sparkle", "Sparkle", -768 + 120, 0.5, "linear")
    end

    if tag == 'enable' then
        finish = true
        makeLuaSprite("pressSpace", "pressSpace", 256, 0)
        scaleObject("pressSpace", 3.0, 3.0)
        addLuaSprite("pressSpace")
        setProperty('pressSpace.antialiasing', false)
        setObjectCamera('pressSpace', 'other')

        --makeLuaText("Accuracy", "Accuracy:"..callMethodFromClass('backend.CoolUtil', 'floorDecimal', {getProperty('ratingPercent')*100, 2}).."%\nTries:"..deaths.."\nMisses:"..misses.."\nHighest Combo:"..highestCombo.."\nPress ENTER to Continue", 1280, 0, 400)
        makeLuaText("Accuracy", "Tries:"..deaths.."\nMisses:"..misses.."\nHighest Combo:"..highestCombo, 1280, 250, 300)
        setTextAlignment('Accuracy','left')
        setTextSize('Accuracy', 6*5, 6*5)
        setTextFont("Accuracy", "sonic-1-hud-font.ttf")
        addLuaText("Accuracy", false)
        setObjectCamera('Accuracy', 'other')

        runTimer('flash1', 0.5, 99)

        playSound("End", 1, 'End')
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

    if tag == 'fadeBlack' then

        makeLuaSprite("blue", 0, 0)
        makeGraphic('blue', 2000, 2000, '0000FF')
        setScrollFactor('blue', 0, 0)
        setObjectCamera('blue', 'other')
        setProperty('blue.antialiasing', false)
        addLuaSprite('blue',true)
        setBlendMode("blue", 'multiply')
        setProperty('blue.alpha', 0.0)

        doTweenAlpha("blue", "blue", 1, 0.3, "sineOut")
        cameraFade("other", "000000", 0.5, 'linear')

        runTimer("end", 1)
    end

    if tag == 'end' then
        endSong()
    end
end