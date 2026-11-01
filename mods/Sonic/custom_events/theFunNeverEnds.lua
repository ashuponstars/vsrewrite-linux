function onCreate()
    precacheImage("theFunNeverEnds")
end

function onCreatePost()
    makeAnimatedLuaSprite("theFunNeverEnds", "theFunNeverEnds", 230, 0)
    addAnimationByPrefix('theFunNeverEnds', 'THE', '1the', 1, false)
    addAnimationByPrefix('theFunNeverEnds', 'FUN', '2fun', 1, false)
    addAnimationByPrefix('theFunNeverEnds', 'NE', '3ne', 1, false)
    addAnimationByPrefix('theFunNeverEnds', 'NEVER', '4never', 1, false)
    addAnimationByPrefix('theFunNeverEnds', 'ENDS', '5ends', 1, false)
    playAnim("theFunNeverEnds", "THE", true, false, 0)
    setProperty('theFunNeverEnds.antialiasing', false)
    addLuaSprite('theFunNeverEnds', false)
    scaleObject("theFunNeverEnds", 3.0, 3.0)
    setObjectCamera("theFunNeverEnds", 'hud')
    screenCenter('theFunNeverEnds', 'X')
    setProperty("theFunNeverEnds.visible", false)
end

function onEvent(name, value1, value2)
    if name == 'theFunNeverEnds' then        
        if value1 == '' then
            setProperty("theFunNeverEnds.visible", false)
        else
            setProperty("theFunNeverEnds.visible", true)
            playAnim("theFunNeverEnds", string.upper(value1), true, false, 0)
        end
    end
end