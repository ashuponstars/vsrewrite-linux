local hasRetried = false
local rodentRapSubtitles = {
    [0] = function ()
        doSubtitles("FACE THE WRATH OF MY RODENTRAP!")
    end,

    [1] = function ()
        doSubtitles("WOW, I GOTTA SAY!")
        runTimer("rodentrap1", 2.2)
    end,

    [2] = function ()
        doSubtitles("YOU'RE NOT VERY GOOD AT THIS, ARE YOU?")
    end,

    [3] = function ()
        doSubtitles("YOUR LEGACY WON'T BE ONE TO REMEMBER!")
    end,

    [4] = function ()
        doSubtitles("I ONLY NEED YOU TO TRY...")
        runTimer("rodentrap4", 2.72)
        runTimer("rodentrap4.5", 3.94)
    end,

    [5] = function ()
        doSubtitles("HEY!")
        runTimer("rodentrap5", 0.97)
    end,

    [6] = function ()
        doSubtitles("TIME TO WRITE YOUR OBITUARY!")
    end,

    [7] = function ()
        doSubtitles("YOU'RE TOO SLOW!")
        runTimer("rodentrap7", 1.92)
    end,

    [8] = function ()
        doSubtitles("COME ON!")
        runTimer("rodentrap8", 0.94)
    end,

    [9] = function ()
        doSubtitles("WHY NOT TRY AGAIN?")
    end,

    [10] = function ()
        doSubtitles("KEEP IT UP AND DON'T GET LEFT BEHIND!")
    end,
    -- scary mode activate
    [11] = function ()
        doSubtitles("TRY AGAIN.")
    end,

    [12] = function ()
        doSubtitles("TOO SLOW.")
    end,

    [13] = function ()
        doSubtitles("KEEP COUNT OF YOUR TRIES.")
    end,

    [14] = function ()
        doSubtitles("READY OR NOT...")
        runTimer("rodentrap14", 1.37)
    end,

    [15] = function ()
        doSubtitles("HIDE AND SEEK, CAN'T YOU SEE?")
    end,

    [16] = function ()
        doSubtitles("PLAY THE NOTES, YOU'RE SO FUN...")
    end,
}

function onGameOverStart()
    makeLuaText("subtitles", "", 820, 230, 600)
    setTextSize("subtitles", 46)
    setScrollFactor('subtitles', 0,0)
    setObjectCamera('subtitles', 'other')
    setTextColor("subtitles", "FFFFFF")
    addLuaText("subtitles")
    setTextFont("subtitles", "tardling.ttf") -- FONT BY HL_SHIRO
    setTextBorder("subtitles", 1.7, "000000", "outline")
    setProperty('subtitles.alpha', 0.001)
    setProperty('subtitles.antialiasing', false)
    setTextAlignment("subtitles", 'center')
end

function doSubtitles(text)
    setTextString("subtitles", text)
    setProperty("subtitles.alpha", 1)
end

function onGameOverLoopStart()
    runTimer('doVoiceLine', 1)
end

function onGameOverConfirm()
    hasRetried = true
    cancelTimer("doVoiceLine")
    stopSound("voiceLine")
    setProperty("subtitles.visible", false)
end

function onSoundFinished(tag)
    if tag == "voiceLine" and not hasRetried then
        runHaxeCode([[
            FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.15);
        ]]);
        doTweenAlpha("subtitleTween", "subtitles", 0.001, 0.2, "linear")
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if tag == "doVoiceLine" then
        line = getRandomInt(0, 16)
        playSound("gameOverLines/XRodentRap/"..line, 1, "voiceLine")
        runHaxeCode([[
            FlxTween.tween(FlxG.sound.music, {volume: 0.35}, 0.175);
        ]]);
        rodentRapSubtitles[line]()
    end

    if tag == "rodentrap1" then
        doSubtitles("YOU REALLY CAN'T KEEP PACE, CAN YOU?")
    end

    if tag == "rodentrap4" then
        doSubtitles("AGAIN...")
    end

    if tag == "rodentrap4.5" then
        doSubtitles("WITH ME...")
    end

    if tag == "rodentrap5" then
        doSubtitles("I THINK I KNOW YOU FROM SOMEWHERE...")
    end

    if tag == "rodentrap7" then
        doSubtitles("WANT TO TRY AGAIN?")
    end

    if tag == "rodentrap8" then
        doSubtitles("KEEP IT UP, WILL YA?")
    end

    if tag == "rodentrap14" then
        doSubtitles("HERE I COME.")
    end
end