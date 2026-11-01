local windowOriginX = 0
local windowOriginY = 0

function onCreatePost()
    windowOriginX = getProperty("windowOriginXPublic")
    windowOriginY = getProperty("windowOriginYPublic")
end

function onEvent(name, value1, value2, strumTime)
    if strumTime > checkpointTime then -- checkpoint check
        if windowFuckery then -- option check
            if name == "MajinWindowGlitchThing" then
                setPropertyFromClass('openfl.Lib','application.window.x', windowOriginX + 230 + getRandomFloat(-50, 50))
                setPropertyFromClass('openfl.Lib','application.window.y', windowOriginY + getRandomFloat(-50, 50))
            end
        end
    end
end