local glitchIntro = 0

function onCreate()
    for i = 0,14 do
        precacheImage("modelSwap/"..i) -- just in case
    end
end

function onCreatePost()
    makeLuaSprite("glitchIntro", "modelSwap/0", 0, 0)
    setProperty('glitchIntro.antialiasing', false)
    setProperty('glitchIntro.alpha', 0.001)
    addLuaSprite('glitchIntro', false)
    setObjectCamera("glitchIntro", 'hud')
    scaleObject("glitchIntro", 3.22, 3.22)
end

function onEvent(name, value1, value2)
    if name == 'introGlitch' then
        if value1 ~= 'hide' then
            setProperty('glitchIntro.alpha', 1)
            
            if glitchIntro >= 12 then
                glitchIntro = 1
            else
                glitchIntro = glitchIntro + 1
            end
            setProperty("glitchIntro.visible", true)
            loadGraphic("glitchIntro", "modelSwap/"..glitchIntro)
        else
            setProperty("glitchIntro.visible", false)
        end
    end
end