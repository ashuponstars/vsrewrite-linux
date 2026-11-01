local num = 0
local laNum = 1
local countNum = 4

local swap = false
local first = true

local countdownTGEMoment = {
    [3] = function()
        playAnim('countdownTGE', 'three', true)
    end,

    [2] = function()
        playAnim('countdownTGE', 'two', true)
    end,

    [1] = function()
        playAnim('countdownTGE', 'one', true)
    end,

    [0] = function()
        playAnim('countdownTGE', 'go', true)
    end,

    [-1] = function()
        removeLuaSprite('countdownTGE', true)
    end,
}

local eventTrigger = { --WOW A SWITCH CASE IN LUA? SNOW'S MOVING UP IN THE WORLD!!!
    [1] = function() --ARE YOU READY?
        makeAnimatedLuaSprite('are', 'tgeBG/tgeLyrics', 550, 500)
        addAnimationByPrefix('are', 'are', '1are', 1, false) 
        scaleObject('are', 2, 2)
        setProperty('are.alpha', 0)
        setProperty('are.antialiasing', false)
        addLuaSprite('are', true)

        doTweenAlpha('are', 'are', 1, 0.5, 'quadOut')
    end,

    [2] = function()
        makeAnimatedLuaSprite('you', 'tgeBG/tgeLyrics', getProperty('are.x') + 100, getProperty('are.y') + 75)
        addAnimationByPrefix('you', 'you', '2you', 1, false) 
        scaleObject('you', 2, 2)
        setProperty('you.alpha', 0)
        setProperty('you.antialiasing', false)
        addLuaSprite('you', true)

        doTweenAlpha('you', 'you', 1, 0.5, 'quadOut')
    end,

    [3] = function()
        makeAnimatedLuaSprite('ready', 'tgeBG/tgeLyrics', getProperty('you.x') + 30, getProperty('you.y') + 100)
        addAnimationByPrefix('ready', 'ready', '3ready', 1, false) 
        scaleObject('ready', 2, 2)
        setProperty('ready.alpha', 0)
        setProperty('ready.antialiasing', false)
        addLuaSprite('ready', true)

        doTweenAlpha('ready', 'ready', 1, 0.5, 'quadOut')
    end,

    [4] = function()
        doTweenAlpha('areDelete', 'are', 0, 0.5, 'linear')
        doTweenAlpha('you', 'you', 0, 0.5, 'linear')
        doTweenAlpha('ready', 'ready', 0, 0.5, 'linear')
    end,

    [5] = function() -- SERIOUSLY, DREADING?
        makeAnimatedLuaSprite('マジで', 'tgeBG/tgeLyrics', 330, 500)
        addAnimationByPrefix('マジで', 'seriously', '1seriously', 1, false) 
        scaleObject('マジで', 2, 2)
        setProperty('マジで.antialiasing', false)
        setObjectOrder('マジで', getObjectOrder('frontLayer')-1)
        setScrollFactor('マジで', 0.6, 0.6)
        addLuaSprite('マジで', false)

        doTweenY('マジで', 'マジで', 280, 0.5, 'quadOut')
    end,

    [6] = function()
        makeAnimatedLuaSprite('dreading', 'tgeBG/tgeLyrics', 340, 500)
        addAnimationByPrefix('dreading', 'dreading', '2dreading', 1, false) 
        scaleObject('dreading', 2, 2)
        setProperty('dreading.antialiasing', false)
        setObjectOrder('dreading', getObjectOrder('frontLayer')-1)
        setScrollFactor('dreading', 0.6, 0.6)
        addLuaSprite('dreading', false)

        doTweenY('dreading', 'dreading', 350, 0.5, 'quadOut')
    end,

    [7] = function()
        doTweenAlpha('マジでdelete', 'マジで', 0, 0.5, 'linear')
        doTweenAlpha('dreading', 'dreading', 0, 0.5, 'linear')

        --

        makeAnimatedLuaSprite('itsawaste', 'tgeBG/tgeLyrics', 200, 700)
        addAnimationByPrefix('itsawaste', '1', '1itsawaste', 1, false)
        addAnimationByPrefix('itsawaste', '2', '2itsawaste', 1, false) 
        addAnimationByPrefix('itsawaste', '3', '3itsawaste', 1, false) 
        setProperty('itsawaste.antialiasing', false)
        playAnim('itsawaste', '1', true)
        scaleObject('itsawaste', 2, 2)
        setObjectOrder('itsawaste', getObjectOrder('backLayer')+1)
        setScrollFactor('itsawaste', 1, 1)
        addLuaSprite('itsawaste', false)

        doTweenX('itsawaste', 'itsawaste', 560, 0.5, 'quadOut')
    end,

    [8] = function()
        playAnim('itsawaste', '2', true)
    end,

    [9] = function()
        playAnim('itsawaste', '3', true)
    end,

    [10] = function()
        doTweenAlpha('itsawastedelete', 'itsawaste', 0, 0.5, 'linear')
    end,

    [11] = function() --BE NOT AFRAID
        makeAnimatedLuaSprite('be', 'tgeBG/tgeLyrics', 550, 650)
        addAnimationByPrefix('be', 'be', '1be', 1, false) 
        scaleObject('be', 2, 2)
        setProperty('be.antialiasing', false)
        setProperty('be.alpha', 0)
        addLuaSprite('be', true)

        doTweenAlpha('be', 'be', 1, 0.5, 'quadOut')
        doTweenAlpha('camHUD', 'camHUD', 0, 0.25, 'quadOut')
    end,

    [12] = function()
        makeAnimatedLuaSprite('not', 'tgeBG/tgeLyrics', getProperty('be.x') + 80, getProperty('be.y'))
        addAnimationByPrefix('not', 'not', '2not', 1, false) 
        scaleObject('not', 2, 2)
        setProperty('not.alpha', 0)
        setProperty('not.antialiasing', false)
        addLuaSprite('not', true)

        doTweenAlpha('not', 'not', 1, 0.5, 'quadOut')
    end,

    [13] = function()
        makeAnimatedLuaSprite('afraid', 'tgeBG/tgeLyrics', getProperty('not.x') - 420 , getProperty('not.y') + 75)
        addAnimationByPrefix('afraid', 'afraid', '3afraid', 1, false) 
        scaleObject('afraid', 2, 2)
        setProperty('afraid.alpha', 0)
        setProperty('afraid.antialiasing', false)
        addLuaSprite('afraid', true)

        doTweenAlpha('afraid', 'afraid', 1, 0.5, 'quadOut')
    end,

    [14] = function()
        doTweenAlpha('beDelete', 'be', 0, 0.5, 'linear')
        doTweenAlpha('notDelete', 'not', 0, 0.5, 'linear')
        doTweenAlpha('afraidDelete', 'afraid', 0, 0.5, 'linear')
    end,

    [15] = function()
        makeAnimatedLuaSprite('its', 'tgeBG/tgeLyrics', 0, 630)
        addAnimationByPrefix('its', 'its', '1its0', 1, false) 
        scaleObject('its', 2, 2)
        setProperty('its.alpha', 1)
        setProperty('its.antialiasing', false)
        addLuaSprite('its', false)

        doTweenX('its', 'its', 800, 0.75, 'quadOut')
    end,

    [16] = function()
        makeAnimatedLuaSprite('all', 'tgeBG/tgeLyrics', 1000, 700)
        addAnimationByPrefix('all', 'all', '2all', 0.5, false) 
        scaleObject('all', 2, 2)
        setProperty('all.alpha', 1)
        setProperty('all.antialiasing', false)
        addLuaSprite('all', false)

        doTweenX('all', 'all', 680, 0.75, 'quadOut')
    end,

    [17] = function()
        makeAnimatedLuaSprite('okay', 'tgeBG/tgeLyrics', 730, 1100)
        addAnimationByPrefix('okay', 'okay', '3okay', 1, false) 
        scaleObject('okay', 2, 2)
        setProperty('okay.alpha', 1)
        setProperty('okay.antialiasing', false)
        addLuaSprite('okay', false)
        setObjectOrder('okay', getObjectOrder('backLayer')+1)

        doTweenY('okay', 'okay', 780, 0.75, 'quadOut')
    end,

    [18] = function()
        doTweenAlpha('itsDelete', 'its', 0, 0.5, 'linear')
        doTweenAlpha('allDelete', 'all', 0, 0.5, 'linear')
        doTweenAlpha('okayDelete', 'okay', 0, 0.5, 'linear')

        makeAnimatedLuaSprite('lets', 'tgeBG/tgeLyrics', 400, 0)
        addAnimationByPrefix('lets', 'lets', '1lets', 1, false) 
        scaleObject('lets', 2, 2)
        setScrollFactor('lets', 0, 0)
        setProperty('lets.antialiasing', false)
        addLuaSprite('lets', true)

        doTweenY('lets', 'lets', 100, 0.5, 'quadOut')
    end,

    [19] = function()
        makeAnimatedLuaSprite('play', 'tgeBG/tgeLyrics', getProperty('lets.x') + 100, 0)
        addAnimationByPrefix('play', 'play', '2play', 1, false) 
        scaleObject('play', 2, 2)
        setScrollFactor('play', 0, 0)
        setProperty('play.antialiasing', false)
        addLuaSprite('play', true)

        doTweenY('play', 'play', 95, 0.5, 'quadOut')
    end,

    [20] = function()
        makeAnimatedLuaSprite('a', 'tgeBG/tgeLyrics', getProperty('play.x') + 120, 0)
        addAnimationByPrefix('a', 'a', '3a0', 1, false) 
        scaleObject('a', 2, 2)
        setScrollFactor('a', 0, 0)
        setProperty('a.antialiasing', false)
        addLuaSprite('a', true)

        doTweenY('a', 'a', 100, 0.5, 'quadOut')
    end,
    
    [21] = function()
        makeAnimatedLuaSprite('1game', 'tgeBG/tgeLyrics', getProperty('a.x') + 80, 0)
        addAnimationByPrefix('1game', '1game', '4game', 1, false) 
        scaleObject('1game', 2, 2)
        setScrollFactor('1game', 0, 0)
        setProperty('1game.antialiasing', false)
        addLuaSprite('1game', true)

        doTweenY('1game', '1game', 80, 0.5, 'quadOut')
    end,

    [22] = function()
        makeAnimatedLuaSprite('1for', 'tgeBG/tgeLyrics', 335, 720)
        addAnimationByPrefix('1for', '1for', '1for', 1, false) 
        scaleObject('1for', 2, 2)
        setScrollFactor('1for', 0, 0)
        setProperty('1for.antialiasing', false)
        addLuaSprite('1for', true)

        doTweenY('1for', '1for', 500, 0.5, 'quadOut')
    end,

    [23] = function()
        makeAnimatedLuaSprite('old', 'tgeBG/tgeLyrics', getProperty('1for.x') + 120 , 720)
        addAnimationByPrefix('old', 'old', '2old', 1, false) 
        scaleObject('old', 2, 2)
        setScrollFactor('old', 0, 0)
        setProperty('old.antialiasing', false)
        addLuaSprite('old', true)

        doTweenY('old', 'old', 520, 0.5, 'quadOut')
    end,

    [24] = function()
        makeAnimatedLuaSprite('times', 'tgeBG/tgeLyrics', getProperty('old.x') + 130 , 720)
        addAnimationByPrefix('times', 'times', '3times', 1, false) 
        scaleObject('times', 2, 2)
        setScrollFactor('times', 0, 0)
        setProperty('times.antialiasing', false)
        addLuaSprite('times', true)

        doTweenY('times', 'times', 490, 0.5, 'quadOut')
    end,

    [25] = function()
        makeAnimatedLuaSprite('sake', 'tgeBG/tgeLyrics', getProperty('times.x') + 150 , 720)
        addAnimationByPrefix('sake', 'sake', '4sake', 1, false) 
        scaleObject('sake', 2, 2)
        setScrollFactor('sake', 0, 0)
        setProperty('sake.antialiasing', false)
        addLuaSprite('sake', true)

        doTweenY('sake', 'sake', 510, 0.5, 'quadOut')
    end,

    [26] = function()
        removeLuaSprite('lets', true)
        removeLuaSprite('play', true)
        removeLuaSprite('a', true)
        removeLuaSprite('1game', true)

        removeLuaSprite('1for', true)
        removeLuaSprite('old', true)
        removeLuaSprite('times', true)
        removeLuaSprite('sake', true)

        setProperty('camHUD.alpha', 1)
    end,

    [27] = function()
        makeAnimatedLuaSprite('youareflawed', 'tgeBG/tgeLyrics', 150, 720)
        addAnimationByPrefix('youareflawed', 'you', '1you2', 1, false)
        addAnimationByPrefix('youareflawed', 'are', '2are2', 1, false)
        addAnimationByPrefix('youareflawed', 'flawed', '3flawed', 1, false)
        playAnim('youareflawed', 'you')
        scaleObject('youareflawed', 2, 2)
        setProperty('youareflawed.antialiasing', false)
        addLuaSprite('youareflawed', true)
    end,

    [28] = function()
        playAnim('youareflawed', 'are')
    end,

    [29] = function()
        playAnim('youareflawed', 'flawed')
    end,

    [30] = function()
        removeLuaSprite('youareflawed', true)

        makeAnimatedLuaSprite('iamgod', 'tgeBG/tgeLyrics', 650, 720)
        addAnimationByPrefix('iamgod', 'i', '1i0', 1, false)
        addAnimationByPrefix('iamgod', 'am', '2am0', 1, false)
        addAnimationByPrefix('iamgod', 'god', '3god0', 1, false)
        playAnim('iamgod', 'i')
        scaleObject('iamgod', 2, 2)
        setProperty('iamgod.antialiasing', false)
        addLuaSprite('iamgod', true)
    end,

    [31] = function()
        playAnim('iamgod', 'am')
    end,

    [32] = function()
        playAnim('iamgod', 'god')
    end,

    [33] = function()
        removeLuaSprite('iamgod', true)
    end,

    [34] = function()

        -- moved this here cuz the lyrics were appearing before the camera fade lol
        
        --callMethod('camGame.fade', {0x000000, 0.25, true})
        --callMethod('camOther.fade', {0x000000, 0.25, true})
        --setProperty('iAmSonic.alpha', 1) 

        doTweenAlpha('blue', 'blue', 0, 0.3, 'quadIn')
        doTweenColor('iAmSonic', 'iAmSonic', '070727', 0.0001, 'quadOut')
        doTweenColor('iAmSonic', 'iAmSonic', 'FFFFFF', 0.25, 'quadOut') -- not the lyrics, the render, found in the windowStuff script

        makeAnimatedLuaSprite('iamSonic', 'tgeBG/tgeLyrics', 325, 100)
        addAnimationByPrefix('iamSonic', 'i', '1i20', 1, false)
        addAnimationByPrefix('iamSonic', 'am', '2am20', 1, false)
        addAnimationByPrefix('iamSonic', 'sonic', '3sonic0', 1, false)
        addAnimationByPrefix('iamSonic', 'sawnick', '4sonicFucked0', 1, false)
        playAnim('iamSonic', 'i')
        scaleObject('iamSonic', 3, 3)
        setObjectCamera('iamSonic', 'other')
        setProperty('iamSonic.antialiasing', false)
        addLuaSprite('iamSonic', true)
    end,

    [35] = function()
        playAnim('iamSonic', 'am')
    end,

    [36] = function()
        playAnim('iamSonic', 'sonic')
    end,

    [37] = function()
        playAnim('iamSonic', 'sawnick')
    end,

    [38] = function()
        removeLuaSprite('iamSonic', true)
    end
}

function onCreate()
    makeAnimatedLuaSprite('countdownTGE', 'countdown', 570, 275)
    addAnimationByPrefix('countdownTGE', 'three', 'three', 10, false)
    addAnimationByPrefix('countdownTGE', 'two', 'two', 10, false) 
    addAnimationByPrefix('countdownTGE', 'one', 'one', 10, false) 
    addAnimationByPrefix('countdownTGE', 'go', 'go', 15, false) 
    setProperty('countdownTGE.antialiasing', false)
    playAnim('countdownTGE', 'three', true)
    scaleObject('countdownTGE', 1, 1)
    setScrollFactor('countdownTGE', 0, 0)
    setProperty('countdownTGE.alpha', 0.001)
    addLuaSprite('countdownTGE', true)
end

function onEvent(name, value1, value2)
    if name == 'tgeLyrics' then

        if value1 == 'la' then --the "la"s
            local offsetX = 100
            local offsetY = -30

            makeAnimatedLuaSprite('la'..laNum, 'tgeBG/tgeLyrics', getProperty('dad.x')+offsetX, getProperty('dad.y')+offsetY)
            addAnimationByPrefix('la'..laNum, 'la'..laNum, getRandomInt(1, 7)..'la', 1, false) 
            scaleObject('la'..laNum, 2, 2)
            setProperty('la'..laNum..'.antialiasing', false)
            addLuaSprite('la'..laNum, false)
    
            doTweenX('laX'..laNum, 'la'..laNum, getProperty('la'..laNum..'.x')+getRandomInt(200, 300), 1, 'linear')
            doTweenY('laY'..laNum, 'la'..laNum, getProperty('la'..laNum..'.y')+getRandomInt(-200, -100), 1, 'linear')
            doTweenAlpha('laAlpha'..laNum, 'la'..laNum, 0, 1, 'quadIn')
    
            laNum = laNum + 1
        else
            if value2 == "" then
                num = num + 1 -- display next lyric
                eventTrigger[num]()
            end

            if value2 == "schmoovin" then -- commented out cuz idk if this is being used or not, chances are no, will remove entirely if confirmed not
                --[[
                if not swap then
                    if first then
                        doTweenY('lets', 'lets', getProperty('lets.y') -20, 0.05, 'linear')
                        doTweenY('play', 'play', getProperty('play.y') +20, 0.05, 'linear')
                        doTweenY('a', 'a', getProperty('a.y') -20, 0.05, 'linear')
                        doTweenY('1game', '1game', getProperty('1game.y') +20, 0.05, 'linear')

                        doTweenY('1for', '1for', getProperty('1for.y') +40, 0.05, 'linear')
                        doTweenY('old', 'old', getProperty('old.y') -40, 0.05, 'linear')
                        doTweenY('times', 'times', getProperty('times.y') +40, 0.05, 'linear')
                        doTweenY('sake', 'sake', getProperty('sake.y') -40, 0.05, 'linear')
                        first = false
                    else
                        doTweenY('lets', 'lets', getProperty('lets.y') -40, 0.05, 'linear')
                        doTweenY('play', 'play', getProperty('play.y') +40, 0.05, 'linear')
                        doTweenY('a', 'a', getProperty('a.y') -40, 0.05, 'linear')
                        doTweenY('1game', '1game', getProperty('1game.y') +40, 0.05, 'linear')

                        doTweenY('1for', '1for', getProperty('1for.y') +40, 0.05, 'linear')
                        doTweenY('old', 'old', getProperty('old.y') -40, 0.05, 'linear')
                        doTweenY('times', 'times', getProperty('times.y') +40, 0.05, 'linear')
                        doTweenY('sake', 'sake', getProperty('sake.y') -40, 0.05, 'linear')
                    end

                    swap = true
                else
                    doTweenY('lets', 'lets', getProperty('lets.y') +40, 0.05, 'linear')
                    doTweenY('play', 'play', getProperty('play.y') -40, 0.05, 'linear')
                    doTweenY('a', 'a', getProperty('a.y') +40, 0.05, 'linear')
                    doTweenY('1game', '1game', getProperty('1game.y') -40, 0.05, 'linear')

                    doTweenY('1for', '1for', getProperty('1for.y') -40, 0.05, 'linear')
                    doTweenY('old', 'old', getProperty('old.y') +40, 0.05, 'linear')
                    doTweenY('times', 'times', getProperty('times.y') -40, 0.05, 'linear')
                    doTweenY('sake', 'sake', getProperty('sake.y') +40, 0.05, 'linear')

                    swap = false
                end
                ]]
            end
            

            if value2 == "vanish" then 
                doTweenAlpha('lets', 'lets', 0, 0.5, 'linear')
                doTweenAlpha('play', 'play', 0, 0.5, 'linear')
                doTweenAlpha('a', 'a', 0, 0.5, 'linear')
                doTweenAlpha('1game', '1game', 0, 0.5, 'linear')

                doTweenAlpha('1for', '1for', 0, 0.5, 'linear')
                doTweenAlpha('old', 'old', 0, 0.5, 'linear')
                doTweenAlpha('times', 'times', 0, 0.5, 'linear')
                doTweenAlpha('sake', 'sake', 0, 0.5, 'linear')
            end

            if value2 == "countdown" then
                setProperty('countdownTGE.alpha', 1)
                countNum = countNum - 1 -- display next lyric
                countdownTGEMoment[countNum]()
            end
        end
    end

    if value2 == 'resetNum' then -- idk just in case this is needed for some testing bs
        num = 0
    end

    if value2 == 'delete' then
        for i=0,laNum do
            removeLuaSprite('la'..i) -- remove the "la"s
        end

        laNum = 1
    end
end

function onTweenCompleted(tag) -- just some tweens to remove objects when unused
    if tag == 'areDelete' then
        removeLuaSprite('are')
        removeLuaSprite('you')
        removeLuaSprite('ready')
    end

    if tag == 'マジでdelete' then
        removeLuaSprite('マジで')
        removeLuaSprite('dreading')
    end

    if tag == 'itsawastedelete' then
        removeLuaSprite('itsawaste')
    end

    if tag == 'beDelete' then
        removeLuaSprite('be')
        removeLuaSprite('not')
        removeLuaSprite('afraid')
    end

    if tag == 'itsDelete' then
        removeLuaSprite('its')
        removeLuaSprite('all')
        removeLuaSprite('okay')
    end
end